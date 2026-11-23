#!/usr/bin/env python3
"""pp2ghostfolio: Import a Portfolio Performance file into Ghostfolio.

Reads a Portfolio Performance file (encrypted .portfolio, plain XML, or
zipped XML), extracts all security transactions (buys, sells, deliveries,
transfers, dividends, interest, fees), and imports them into a self-hosted
Ghostfolio instance via its REST API, creating one Ghostfolio account per
PP account that holds security-related transactions.

Usage:
  pp2ghostfolio.py FILE --url https://ghostfolio.example.org \
      --token GHOSTFOLIO_SECRET [--password PP_PASSWORD] [--dry-run]

PP file format (from ClientFactory.java in portfolio-performance/portfolio):
  - Encrypted: 8-byte "PORTFOLIO" signature + 1 byte method (0=AES128,
    1=AES256) + 16-byte IV, then AES-CBC-PKCS5 ciphertext. Key derived
    with PBKDF2-HmacSHA1 (fixed 16-byte salt, 65536 iterations) from the
    password. Inside the ciphertext: 4-byte content type (1=XML,
    2=protobuf), 4-byte version, then a ZIP archive with one entry.
  - Plain XML: XStream serialization directly.
  - Plain ZIP (PK\\x03\\x04): ZIP archive containing data.xml.

PP scaling (from money/Values.java):
  - Money amounts: stored as long, divide by 100 (precision 2)
  - Shares: stored as long, divide by 10_000_000 (precision 8)
  - unitPrice = grossValue / shares (computed from scaled values)

PP transaction semantics (from PortfolioTransaction.getGrossValueAmount):
  - BUY:      amount = gross + fees + taxes  =>  gross = amount - fees - taxes
  - SELL:     amount = gross - fees - taxes  =>  gross = amount + fees + taxes
  - DIVIDENDS (AccountTransaction, isCredit): amount stored positive
    (gross = amount + fees + taxes in PP terms; net payout = amount)

Ghostfolio models an activity as: quantity * unitPrice ± fee on account.
  - BUY/SELL: unitPrice = gross/shares, fee = fees + taxes
  - DIVIDEND: quantity = shares (or 1), unitPrice = net per share
"""

import argparse
import getpass
import hashlib
import json
import sys
import urllib.error
import urllib.request
import zipfile
import io

import xml.etree.ElementTree as ET

# --- PP decryption constants (ClientFactory.java, Decryptor) ---
PP_SIGNATURE = b"PORTFOLIO"
PP_SALT = bytes([112, 67, 103, 107, 164, 131, 144, 161,
                 159, 142, 117, 200, 203, 187, 231, 228])
PP_ITERATIONS = 65536

MONEY_DIVISOR = 100          # PP money precision: 2 decimal digits
SHARE_DIVISOR = 100_000_000  # PP share precision: 8 decimal digits (10^8)


# ---------------------------------------------------------------------------
# Reading / decryption
# ---------------------------------------------------------------------------

def read_pp(path: str, password: str | None) -> "PPClientXML | PPClientProto":
    """Read any Portfolio Performance file and return the parsed client."""
    with open(path, "rb") as f:
        data = f.read()

    content_type = None
    if data.startswith(PP_SIGNATURE):
        if password is None:
            password = getpass.getpass("Portfolio Performance password: ")
        data, content_type = decrypt_pp(data, password)

    if data[:2] == b"PK":
        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            data = zf.read(zf.namelist()[0])
        if data.lstrip().startswith(b"<"):
            import xml.etree.ElementTree as ET
            return PPClientXML(ET.fromstring(data.decode("utf-8")))
        # protobuf body (ProtobufWriter): strip the PPPBV1 signature
        PPPB_SIG = b"PPPBV1"
        if data[:len(PPPB_SIG)] == PPPB_SIG:
            data = data[len(PPPB_SIG):]
        return PPClientProto(data)

    if data.lstrip().startswith(b"<"):
        import xml.etree.ElementTree as ET
        return PPClientXML(ET.fromstring(data.decode("utf-8")))

    raise ValueError(f"unrecognized Portfolio Performance content "
                     f"(starts with {data[:8]!r})")


def decrypt_pp(data: bytes, password: str) -> tuple[bytes, int]:
    """Decrypt an encrypted .portfolio file (ClientFactory.Decryptor).

    Returns (zipped_payload, content_type) with content_type 1=XML, 2=protobuf.
    """
    try:
        from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    except ImportError:
        sys.exit("error: install 'cryptography' (nix-shell -p python312Packages.cryptography) "
                 "to read encrypted Portfolio Performance files")

    method = data[9]                      # 0 = AES128, 1 = AES256; sig is 9 bytes
    key_bits = 256 if method == 1 else 128
    iv = data[10:26]                      # after 9-byte signature + 1-byte method
    ciphertext = data[26:]

    key = hashlib.pbkdf2_hmac("sha1", password.encode("utf-8"),
                              PP_SALT, PP_ITERATIONS, dklen=key_bits // 8)
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    dec = cipher.decryptor()
    padded = dec.update(ciphertext) + dec.finalize()

    pad_len = padded[-1]
    if not 1 <= pad_len <= 16:
        raise ValueError("decryption failed (wrong password?)")
    plain = padded[:-pad_len]

    content_type = int.from_bytes(plain[0:4], "big")   # 1=XML, 2=protobuf
    version = int.from_bytes(plain[4:8], "big")
    if not (1 <= content_type <= 2 and 1 <= version):
        raise ValueError("decryption failed: bad header (wrong password?)")

    return plain[8:], content_type   # caller unwraps zip (XML) / PPPBV1 sig (protobuf)


# ---------------------------------------------------------------------------
# Minimal protobuf wire-format decoding (schema: model/client.proto in
# portfolio-performance/portfolio). Only what PClient needs: varints,
# 64/32-bit scalars and length-delimited submessages; unknown fields are
# skipped, so schema evolution is not a concern.
# ---------------------------------------------------------------------------

def _varint(buf: bytes, pos: int) -> tuple[int, int]:
    result = 0
    shift = 0
    while True:
        b = buf[pos]
        pos += 1
        result |= (b & 0x7F) << shift
        if not (b & 0x80):
            return result, pos
        shift += 7


def _fields(buf: bytes):
    """Yield (field_number, wire_type, value) for a message buffer."""
    pos = 0
    n = len(buf)
    while pos < n:
        tag, pos = _varint(buf, pos)
        field, wire = tag >> 3, tag & 7
        if wire == 0:      # varint
            val, pos = _varint(buf, pos)
        elif wire == 1:    # 64-bit
            val = buf[pos:pos + 8]
            pos += 8
        elif wire == 2:    # length-delimited
            ln, pos = _varint(buf, pos)
            val = buf[pos:pos + ln]
            pos += ln
        elif wire == 5:    # 32-bit
            val = buf[pos:pos + 4]
            pos += 4
        else:
            raise ValueError(f"unsupported protobuf wire type {wire}")
        yield field, wire, val


def _timestamp_ms(buf: bytes) -> int:
    """google.protobuf.Timestamp message -> epoch milliseconds."""
    sec = 0
    nanos = 0
    for field, wire, val in _fields(buf):
        if field == 1:            # seconds
            sec = val
        elif field == 2:          # nanos
            nanos = val
    return sec * 1000 + nanos // 1_000_000


# ---------------------------------------------------------------------------
# XStream XML parsing
# ---------------------------------------------------------------------------

class PPClientXML:
    """Parsed PP client with XStream reference resolution."""

    def __init__(self, root: ET.Element):
        self.root = root
        self.securities: dict[str, ET.Element] = {}   # uuid -> <security>
        self.accounts: dict[str, ET.Element] = {}      # uuid -> <account>
        self.portfolios: dict[str, ET.Element] = {}    # uuid -> <portfolio>

        # element identity -> parent element
        self._parent: dict[int, ET.Element] = {}
        self._index(root, None)

        # (parent id, tag) -> [children with that tag, in document order]
        self._by_parent_tag: dict[tuple, list] = {}
        self._build_by_parent_tag(root)

        # scan top-level lists; resolve reference-only entries (e.g. a
        # <portfolio reference="..."/> pointing at an inline definition
        # written earlier as part of a crossEntry)
        for sec in root.findall("./securities/security"):
            sec = self._deref(sec)
            u = sec.findtext("uuid")
            if u:
                self.securities[u] = sec
        for acc in root.findall("./accounts/account"):
            acc = self._deref(acc)
            u = acc.findtext("uuid")
            if u:
                self.accounts[u] = acc
        for pf in root.findall("./portfolios/portfolio"):
            pf = self._deref(pf)
            u = pf.findtext("uuid")
            if u:
                self.portfolios[u] = pf

    def _deref(self, elem: ET.Element) -> ET.Element:
        ref = elem.get("reference")
        if ref:
            resolved = self.resolve(elem, ref)
            if resolved is not None:
                return resolved
        return elem

    def _index(self, elem, parent):
        self._parent[id(elem)] = parent
        for child in elem:
            self._index(child, elem)

    def _build_by_parent_tag(self, root):
        def walk(e):
            for child in e:
                self._by_parent_tag.setdefault((id(e), child.tag), []).append(child)
                walk(child)
        walk(root)

    def resolve(self, holder: ET.Element, ref: str) -> ET.Element | None:
        """Resolve an XStream XPATH_RELATIVE_REFERENCE.

        The path is relative to the position of the element carrying the
        reference attribute: each leading "../" moves up one level from
        `holder` itself; named steps descend. Supports name[N] indexes
        (1-based, in document order).
        """
        cur = holder
        for step in ref.split("/"):
            if step == "..":
                cur = self._parent.get(id(cur))
                if cur is None:
                    return None
                continue
            if step == "." or step == "":
                continue
            # indexed reference like security[2]?
            idx = None
            if step.endswith("]") and "[" in step:
                step, idx_s = step[:-1].split("[", 1)
                idx = int(idx_s) - 1
            siblings = self._by_parent_tag.get((id(cur), step), [])
            if not siblings:
                return None
            cur = siblings[idx] if idx is not None and idx < len(siblings) else siblings[0]
        return cur

    def security_of(self, tx: ET.Element) -> ET.Element | None:
        """Resolve the <security> child of a transaction."""
        child = tx.find("security")
        if child is None:
            return None
        ref = child.get("reference")
        if ref:
            target = self.resolve(child, ref)
            return target
        uuid = child.findtext("uuid")
        return self.securities.get(uuid) if uuid else (child if len(child) else None)

    def account_of_portfolio(self, pf: ET.Element) -> ET.Element | None:
        """Resolve the <referenceAccount> child of a portfolio."""
        child = pf.find("referenceAccount")
        if child is None:
            return None
        ref = child.get("reference")
        if ref:
            return self.resolve(child, ref)
        uuid = child.findtext("uuid")
        return self.accounts.get(uuid) if uuid else (child if len(child) else None)

    def text_of(self, elem: ET.Element, tag: str) -> str | None:
        """FindText that resolves XStream references (e.g. <date reference>)."""
        child = elem.find(tag)
        if child is None:
            return None
        ref = child.get("reference")
        if ref:
            target = self.resolve(child, ref)
            return target.text if target is not None else None
        return child.text


class PPClientProto:
    """Parsed PP client from the protobuf format (client.proto).

    Same interface as PPClientXML. Field numbers per PSecurity, PAccount,
    PPortfolio, PTransaction, PTransactionUnit in client.proto.
    """

    # PTransaction.Type enum (client.proto) -> name
    TX_TYPES = {
        0: "PURCHASE", 1: "SALE", 2: "INBOUND_DELIVERY", 3: "OUTBOUND_DELIVERY",
        4: "SECURITY_TRANSFER", 5: "CASH_TRANSFER", 6: "DEPOSIT", 7: "REMOVAL",
        8: "DIVIDEND", 9: "INTEREST", 10: "INTEREST_CHARGE", 11: "TAX",
        12: "TAX_REFUND", 13: "FEE", 14: "FEE_REFUND",
    }
    UNIT_TYPES = {0: "GROSS_VALUE", 1: "TAX", 2: "FEE"}

    def __init__(self, buf: bytes):
        self.securities: dict[str, dict] = {}    # uuid -> {name, ticker, ...}
        self.accounts: dict[str, dict] = {}      # uuid -> {name, currency}
        self.portfolios: dict[str, dict] = {}    # uuid -> {name, refAccount}
        self.transactions: list[dict] = []

        for field, wire, val in _fields(buf):
            if field == 2:    # securities
                sec = self._parse_security(val)
                self.securities[sec["uuid"]] = sec
            elif field == 3:  # accounts
                acc = self._parse_account(val)
                self.accounts[acc["uuid"]] = acc
            elif field == 4:  # portfolios
                pf = self._parse_portfolio(val)
                self.portfolios[pf["uuid"]] = pf
            elif field == 5:  # transactions
                self.transactions.append(self._parse_transaction(val))

    def _parse_security(self, buf: bytes) -> dict:
        sec = {}
        for field, wire, val in _fields(buf):
            if field == 1: sec["uuid"] = val.decode("utf-8")
            elif field == 3: sec["name"] = val.decode("utf-8")
            elif field == 4: sec["currencyCode"] = val.decode("utf-8")
            elif field == 7: sec["isin"] = val.decode("utf-8")
            elif field == 8: sec["tickerSymbol"] = val.decode("utf-8")
        return sec

    def _parse_account(self, buf: bytes) -> dict:
        acc = {}
        for field, wire, val in _fields(buf):
            if field == 1: acc["uuid"] = val.decode("utf-8")
            elif field == 2: acc["name"] = val.decode("utf-8")
            elif field == 3: acc["currencyCode"] = val.decode("utf-8")
        return acc

    def _parse_portfolio(self, buf: bytes) -> dict:
        pf = {}
        for field, wire, val in _fields(buf):
            if field == 1: pf["uuid"] = val.decode("utf-8")
            elif field == 2: pf["name"] = val.decode("utf-8")
            elif field == 5: pf["referenceAccount"] = val.decode("utf-8")
        return pf

    def _parse_transaction(self, buf: bytes) -> dict:
        import datetime
        tx = {"units": [], "type": "PURCHASE"}  # proto3 omits zero: default PURCHASE
        for field, wire, val in _fields(buf):
            if field == 2:
                tx["type"] = self.TX_TYPES.get(val, f"UNKNOWN_{val}")
            elif field == 3: tx["account"] = val.decode("utf-8")
            elif field == 4: tx["portfolio"] = val.decode("utf-8")
            elif field == 5: tx["otherAccount"] = val.decode("utf-8")
            elif field == 6: tx["otherPortfolio"] = val.decode("utf-8")
            elif field == 7: tx["otherUuid"] = val.decode("utf-8")
            elif field == 9:
                ms = _timestamp_ms(val)
                tx["date"] = datetime.datetime.fromtimestamp(
                    ms / 1000, tz=datetime.timezone.utc).isoformat()
            elif field == 10: tx["currencyCode"] = val.decode("utf-8")
            elif field == 11: tx["amount"] = val          # int64 varint
            elif field == 12: tx["shares"] = val           # int64 varint
            elif field == 13: tx["note"] = val.decode("utf-8")
            elif field == 14: tx["security"] = val.decode("utf-8")
            elif field == 15:
                # PTransactionUnit
                unit = {}
                for uf, uw, uv in _fields(val):
                    if uf == 1: unit["type"] = self.UNIT_TYPES.get(uv, f"UNKNOWN_{uv}")
                    elif uf == 2: unit["amount"] = uv
                    elif uf == 3: unit["currencyCode"] = uv.decode("utf-8")
                tx["units"].append(unit)
        return tx

    # -- same accessors as PPClientXML, but dict-based --------------------

    def security_of(self, tx: dict) -> dict | None:
        return self.securities.get(tx.get("security"))

    def account_of_portfolio(self, pf: dict) -> dict | None:
        return self.accounts.get(pf.get("referenceAccount"))


    def proto_convert(self, symbol_map: dict | None = None,
                      skip_symbols: set | None = None):
        """Convert protobuf transactions; returns (accounts, activities, skipped)."""
        accounts: dict[str, dict] = {}
        activities = []
        skipped = []

        def acc_name_of(uuid, fallback):
            acc = self.accounts.get(uuid) if uuid else None
            name = (acc or {}).get("name") or fallback
            currency = (acc or {}).get("currencyCode") or "EUR"
            accounts.setdefault(name, {"name": name, "currency": currency})
            return name

        for tx in self.transactions:
            tx_type = tx.get("type", "")
            date = (tx.get("date") or "").split("T")[0]

            # --- portfolio-side transactions ---
            if tx_type in ("PURCHASE", "SALE", "INBOUND_DELIVERY",
                           "OUTBOUND_DELIVERY", "SECURITY_TRANSFER"):
                if tx_type == "SECURITY_TRANSFER" and tx.get("otherPortfolio"):
                    continue  # mirrored leg; keep only the outbound one
                pf = self.portfolios.get(tx.get("portfolio")) or {}
                pf_name = pf.get("name") or tx.get("portfolio") or "?"
                ref_uuid = pf.get("referenceAccount")
                acc_name = acc_name_of(ref_uuid or tx.get("account"), pf_name)

                gf_type = {"PURCHASE": "BUY", "SALE": "SELL",
                           "INBOUND_DELIVERY": "BUY",
                           "OUTBOUND_DELIVERY": "SELL",
                           "SECURITY_TRANSFER": "SELL"}[tx_type]

                sec = self.security_of(tx)
                # Ghostfolio resolves ISINs against the data provider itself
                # (import.service.ts: "Resolve the symbols with an ISIN"),
                # so the ticker is optional when an ISIN exists.
                symbol = (sec or {}).get("tickerSymbol") or (sec or {}).get("isin")
                symbol = (symbol_map or {}).get(symbol, symbol)
                if symbol in (skip_symbols or set()):
                    skipped.append((date, pf_name, f"skipped by --skip-symbol: {symbol}"))
                    continue
                if not symbol:
                    name = (sec or {}).get("name", "?")
                    skipped.append((date, pf_name, f"security without ticker/isin: {name}"))
                    continue

                amount = tx.get("amount", 0) / MONEY_DIVISOR
                shares = tx.get("shares", 0) / SHARE_DIVISOR
                fees = sum(u.get("amount", 0) for u in tx["units"]
                           if u.get("type") == "FEE") / MONEY_DIVISOR
                taxes = sum(u.get("amount", 0) for u in tx["units"]
                            if u.get("type") == "TAX") / MONEY_DIVISOR

                # PP semantics (PortfolioTransaction.getGrossValueAmount):
                #   purchase: gross = amount - fees - taxes
                #   sale:     gross = amount + fees + taxes
                #   deliveries: amount is the (gross) market value
                if gf_type == "BUY" and tx_type != "INBOUND_DELIVERY":
                    gross = amount - fees - taxes
                elif tx_type == "SALE":
                    gross = amount + fees + taxes
                else:
                    gross = amount  # deliveries / transfers

                unit_price = (gross / shares) if shares > 0 else 0.0

                activities.append({
                    "accountName": acc_name,
                    "symbol": symbol,
                    "type": gf_type,
                    "date": date,
                    "quantity": shares,
                    "unitPrice": round(unit_price, 6),
                    "fee": round(fees + taxes, 2),
                    "comment": tx.get("note") or None,
                })
                continue

            # --- account-side transactions ---
            gf_type_map = {
                "DIVIDEND": "DIVIDEND",
                "INTEREST": "INTEREST",
                "INTEREST_CHARGE": "FEE",
                "FEE": "FEE",
                "FEE_REFUND": "FEE",
                "TAX_REFUND": "FEE",
            }
            gf_type = gf_type_map.get(tx_type)
            if gf_type is None:
                continue  # DEPOSIT/REMOVAL/CASH_TRANSFER etc.

            acc_name = acc_name_of(tx.get("account"), tx.get("account") or "?")

            sec = self.security_of(tx)
            symbol = ((sec or {}).get("tickerSymbol")
                      or (sec or {}).get("isin"))
            symbol = (symbol_map or {}).get(symbol, symbol)
            if symbol in (skip_symbols or set()):
                skipped.append((date, acc_name, f"skipped by --skip-symbol: {symbol}"))
                continue
            if tx_type == "DIVIDEND" and not symbol:
                skipped.append((date, acc_name, "dividend without security"))
                continue
            if not symbol:
                symbol = "CASH"

            amount = tx.get("amount", 0) / MONEY_DIVISOR
            fees = sum(u.get("amount", 0) for u in tx["units"]
                       if u.get("type") == "FEE") / MONEY_DIVISOR
            taxes = sum(u.get("amount", 0) for u in tx["units"]
                        if u.get("type") == "TAX") / MONEY_DIVISOR
            shares = tx.get("shares", 0) / SHARE_DIVISOR

            # PP semantics: credit types store NET; gross = amount + fees + taxes
            if tx_type in ("FEE", "INTEREST_CHARGE"):
                value = abs(amount) - fees - taxes
            else:
                value = amount + fees + taxes

            if shares > 0:
                quantity = shares
                unit_price = value / shares
            else:
                quantity = 1
                unit_price = value

            activities.append({
                "accountName": acc_name,
                "symbol": symbol,
                "type": gf_type,
                "date": date,
                "quantity": quantity,
                "unitPrice": round(max(unit_price, 0), 6),
                "fee": round(fees + taxes, 2),
                "comment": tx.get("note") or None,
            })

        return list(accounts.values()), activities, skipped

def unit_amount(tx: ET.Element, unit_type: str) -> float:
    """Sum PP unit amounts of the given type, in full currency units."""
    total = 0
    units = tx.find("units")
    if units is None:
        return 0.0
    for u in units:
        if u.tag == "unit" and u.get("type") == unit_type:
            amt = u.find("amount")
            if amt is not None and amt.get("amount"):
                total += int(amt.get("amount"))
    return total / MONEY_DIVISOR


def iso_date(text: str | None) -> str:
    return (text or "").split("T")[0]


# ---------------------------------------------------------------------------
# Conversion
# ---------------------------------------------------------------------------

PORTFOLIO_TYPE_MAP = {
    "BUY": "BUY",
    "SELL": "SELL",
    "TRANSFER_IN": "BUY",           # transfer between PP portfolios
    "TRANSFER_OUT": "SELL",
    "DELIVERY_INBOUND": "BUY",       # securities deposit (no cash leg)
    "DELIVERY_OUTBOUND": "SELL",     # securities removal (no cash leg)
}

# Account transactions to import (skip pure cash movements and the
# cash legs of buysell cross-entries, which duplicate portfolio txs).
ACCOUNT_TYPE_MAP = {
    "DIVIDENDS": "DIVIDEND",
    "INTEREST": "INTEREST",
    "FEES": "FEE",
    "FEES_REFUND": "FEE",
    "TAX_REFUND": "FEE",
    "INTEREST_CHARGE": "FEE",
}


def convert(pp: PPClientXML):
    """Return (accounts, activities, skipped)."""
    accounts: dict[str, dict] = {}   # name -> {name, currency}
    activities = []
    skipped = []

    def account_entry(acc: ET.Element | None, fallback_name: str,
                      fallback_currency: str = "EUR") -> str:
        name = (acc.findtext("name") if acc is not None else None) or fallback_name
        currency = (acc.findtext("currencyCode") if acc is not None else None) \
            or fallback_currency
        accounts.setdefault(name, {"name": name, "currency": currency})
        return name

    # --- portfolio transactions ---
    for pf_uuid, pf in pp.portfolios.items():
        pf_name = pf.findtext("name") or pf_uuid
        ref_acc = pp.account_of_portfolio(pf)
        acc_name = account_entry(ref_acc, pf_name)

        for tx in pf.findall("./transactions/portfolio-transaction"):
            date = iso_date(pp.text_of(tx, "date"))
            tx_type = pp.text_of(tx, "type")
            gf_type = PORTFOLIO_TYPE_MAP.get(tx_type)
            if gf_type is None:
                skipped.append((date, pf_name, f"unsupported type {tx_type}"))
                continue

            sec = pp.security_of(tx)
            symbol = sec.findtext("tickerSymbol") if sec is not None else None
            if not symbol:
                name = sec.findtext("name") if sec is not None else "?"
                skipped.append((date, pf_name, f"security without ticker: {name}"))
                continue

            amount = int(tx.findtext("amount") or 0) / MONEY_DIVISOR
            shares = int(tx.findtext("shares") or 0) / SHARE_DIVISOR
            fees = unit_amount(tx, "FEE")
            taxes = unit_amount(tx, "TAX")

            # PP semantics (PortfolioTransaction.getGrossValueAmount):
            #   purchase types: gross = amount - fees - taxes
            #   sale types:      gross = amount + fees + taxes
            if gf_type == "BUY":
                gross = amount - fees - taxes
            else:
                gross = amount + fees + taxes

            unit_price = (gross / shares) if shares > 0 else 0.0

            activities.append({
                "accountName": acc_name,
                "symbol": symbol,
                "type": gf_type,
                "date": date,
                "quantity": shares,
                "unitPrice": round(unit_price, 6),
                "fee": round(fees + taxes, 2),
                "comment": tx.findtext("note") or None,
            })

    # --- account transactions (dividends etc.) ---
    for acc_uuid, acc in pp.accounts.items():
        acc_name = account_entry(acc, acc_uuid)
        acc_currency = accounts[acc_name]["currency"]

        for tx in acc.findall("./transactions/account-transaction"):
            date = iso_date(pp.text_of(tx, "date"))
            tx_type = pp.text_of(tx, "type")
            gf_type = ACCOUNT_TYPE_MAP.get(tx_type)
            if gf_type is None:
                continue  # DEPOSIT/REMOVAL/BUY/SELL cash legs etc.
            if tx.find("crossEntry") is not None and tx_type in ("BUY", "SELL"):
                continue  # never reached; cross-entry legs are BUY/SELL

            sec = pp.security_of(tx)
            symbol = sec.findtext("tickerSymbol") if sec is not None else None
            if tx_type == "DIVIDENDS" and not symbol:
                skipped.append((date, acc_name, "dividend without security"))
                continue
            if tx_type in ("INTEREST", "FEES", "FEES_REFUND",
                           "TAX_REFUND", "INTEREST_CHARGE") and not symbol:
                # cash-only transaction: import with a pseudo symbol
                symbol = "CASH"

            amount = int(tx.findtext("amount") or 0) / MONEY_DIVISOR
            fees = unit_amount(tx, "FEE")
            taxes = unit_amount(tx, "TAX")
            shares = int(tx.findtext("shares") or 0) / SHARE_DIVISOR

            # PP semantics (AccountTransaction.getGrossValueAmount):
            # for credit types (DIVIDENDS, INTEREST, refunds) the stored
            # amount is the NET value; gross = amount + fees + taxes.
            # For debit types (FEES, INTEREST_CHARGE) the stored amount
            # is the charge; gross = amount - fees - taxes (abs for GF).
            if tx_type in ("FEES", "INTEREST_CHARGE"):
                # Ghostfolio FEE: quantity * unitPrice is the fee amount
                value = abs(amount) - fees - taxes
            else:
                value = amount + fees + taxes  # gross

            if shares > 0:
                quantity = shares
                unit_price = value / shares
            else:
                quantity = 1
                unit_price = value

            activities.append({
                "accountName": acc_name,
                "symbol": symbol,
                "type": gf_type,
                "date": date,
                "quantity": quantity,
                "unitPrice": round(max(unit_price, 0), 6),
                "fee": round(fees + taxes, 2),
                "comment": tx.findtext("note") or None,
            })

    return list(accounts.values()), activities, skipped


# ---------------------------------------------------------------------------
# Ghostfolio API
# ---------------------------------------------------------------------------

class Ghostfolio:
    def __init__(self, base_url: str, access_token: str):
        self.base_url = base_url.rstrip("/")
        self.access_token = access_token
        self.jwt = None

    def _req(self, method: str, path: str, body=None, auth: str = "jwt"):
        url = f"{self.base_url}/api/v1{path}"
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Content-Type", "application/json")
        if auth == "jwt":
            req.add_header("Authorization", f"Bearer {self.jwt}")
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                payload = resp.read()
                return json.loads(payload) if payload.strip() else {}
        except urllib.error.HTTPError as e:
            err = e.read().decode(errors="replace")
            raise RuntimeError(f"HTTP {e.code} {method} {path}: {err}") from e

    def login(self):
        r = self._req("POST", "/auth/anonymous",
                      {"accessToken": self.access_token}, auth="none")
        self.jwt = r["authToken"]

    def get_accounts(self) -> list:
        return self._req("GET", "/accounts")["accounts"]

    def create_account(self, name: str, currency: str) -> dict:
        return self._req("POST", "/accounts",
                         {"name": name, "currency": currency,
                          "platformId": None})

    def import_activities(self, payload: dict, dry_run: bool) -> dict:
        path = "/import" + ("?dryRun=true" if dry_run else "")
        return self._req("POST", path, payload)


# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description="Import a Portfolio Performance file into Ghostfolio")
    ap.add_argument("file", help=".portfolio (encrypted), .xml, or .zip file")
    ap.add_argument("--url", required=True,
                    help="Ghostfolio base URL, e.g. https://ghostfolio.example.org")
    ap.add_argument("--token", required=True,
                    help="Ghostfolio access token (the secret shown at signup)")
    ap.add_argument("--password",
                    help="Portfolio Performance password (prompted if encrypted)")
    ap.add_argument("--dry-run", action="store_true",
                    help="validate via the API dry-run but do not import")
    ap.add_argument("--symbol-map", action="append", default=[], metavar="FROM:TO",
                    help="replace a symbol/ISIN with another one, e.g. "
                         "US8740391003:TSM (repeatable)")
    ap.add_argument("--skip-symbol", action="append", default=[],
                    metavar="SYMBOL",
                    help="skip activities for this symbol/ISIN (repeatable)")
    args = ap.parse_args()

    symbol_map = dict(s.split(":", 1) for s in args.symbol_map)
    skip_symbols = set(args.skip_symbol)

    pp = read_pp(args.file, args.password)

    if isinstance(pp, PPClientProto):
        accounts, activities, skipped = pp.proto_convert(symbol_map, skip_symbols)
    else:
        accounts, activities, skipped = convert(pp)

    print(f"PP file: {len(pp.securities)} securities, "
          f"{len(pp.portfolios)} portfolios, {len(pp.accounts)} accounts")
    print(f"Converted {len(activities)} activities into {len(accounts)} account(s)")
    for date, ctx, reason in skipped:
        print(f"  skipped: {date} {ctx}: {reason}", file=sys.stderr)

    for a in activities[:5]:
        print(f"  {a['date']} {a['type']:9} {a['symbol'] or '-':10} "
              f"qty={a['quantity']:.4f} price={a['unitPrice']:.4f} "
              f"fee={a['fee']:.2f} [{a['accountName']}]")
    if len(activities) > 5:
        print(f"  ... and {len(activities) - 5} more")

    gf = Ghostfolio(args.url, args.token)
    gf.login()

    # map account name -> Ghostfolio account id
    existing = {a["name"]: a["id"] for a in gf.get_accounts()}
    name_to_id = {}
    for acc in accounts:
        if acc["name"] in existing:
            name_to_id[acc["name"]] = existing[acc["name"]]
        else:
            created = gf.create_account(acc["name"], acc["currency"])
            name_to_id[acc["name"]] = created["id"]
            print(f"created account {acc['name']!r} ({acc['currency']})")

    # Manual asset profiles for symbols no data provider can resolve
    # (delisted securities): manual symbols need the ghostfolio_ prefix
    # (isValidCustomAssetProfileSymbol in ghostfolio helper.ts).
    is_manual = lambda s: s.startswith("GF_")
    asset_profiles, seen = [], set()
    for a in activities:
        if is_manual(a["symbol"]) and a["symbol"] not in seen:
            seen.add(a["symbol"])
            asset_profiles.append({
                "dataSource": "MANUAL",
                "symbol": a["symbol"],
                "name": a["symbol"].replace("GF_", ""),
                "currency": accounts_by_name(accounts)[a["accountName"]]["currency"],
                "assetClass": "EQUITY",
                "assetSubClass": "STOCK",
                "isActive": False,
            })

    payload = {
        "accounts": [],
        "activities": [
            {
                "accountId": name_to_id[a["accountName"]],
                "comment": a["comment"],
                "currency": accounts_by_name(accounts)[a["accountName"]]["currency"],
                "dataSource": "MANUAL" if is_manual(a["symbol"]) else None,
                "date": a["date"],
                "fee": a["fee"],
                "quantity": a["quantity"],
                "symbol": a["symbol"],
                "type": a["type"],
                "unitPrice": a["unitPrice"],
            }
            for a in activities
        ],
        "assetProfiles": asset_profiles,
    }

    if args.dry_run:
        result = gf.import_activities(payload, dry_run=True)
        print(f"dry-run OK: {len(result.get('activities', []))} activities validated")
        return

    result = gf.import_activities(payload, dry_run=False)
    print(f"imported {len(result.get('activities', []))} activities")


def accounts_by_name(accounts):
    return {a["name"]: a for a in accounts}


if __name__ == "__main__":
    main()
