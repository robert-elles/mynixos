FROM mycomfyui:installed

CMD ["/bin/bash", "-c", "source comfy-env/bin/activate && comfy launch -- --listen 0.0.0.0"]

# docker build -t comfy-app -f mycomfy.Dockerfile .
# docker run 