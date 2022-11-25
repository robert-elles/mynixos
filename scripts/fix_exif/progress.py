import sys


class ProgressBar:
    background = None
    load = None
    head = None
    size = None
    count = 0

    def __init__(self, size, background='-', load="=", head=''):
        self.background = background
        self.load = load
        self.head = head
        self.size = float(size)

    def progress(self, status='', increment=1, flush=True):
        bar_len = 60
        self.count += increment
        filled_len = int(round(bar_len * self.count / self.size))

        percents = round(100 * self.count / self.size, 2)
        if self.head is None:
            bar = self.load * filled_len
        else:
            bar = self.load * (filled_len - 1) + self.head
        bar = bar + self.background * (bar_len - filled_len)

        str2print = '[%s] %s%s ...%s\r' % (bar, percents, '%', status)
        sys.stdout.write('%s\r' % (' ' * len(str2print)))
        if flush:
            sys.stdout.write(str2print)
            sys.stdout.flush()
        else:
            print(str2print)
