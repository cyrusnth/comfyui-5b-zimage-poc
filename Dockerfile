# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""

# 1. Download VAE (Target: models/vae)
# Download VAE from Comfy-Org mirror (No HF Token required)
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do \
    comfy model download \
    --url 'https://huggingface.co/lovis93/testllm/resolve/ed9cf1af7465cebca4649157f118e331cf2a084f/ae.safetensors' \
    --relative-path models/vae \
    --filename 'ae.safetensors' && break; \
    if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; \
    SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; \
    done

# 2. Download Text Encoder (Target: models/clip to match CLIPLoader)
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do \
    HF_TOKEN=$HF_TOKEN comfy model download \
    --url 'https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors' \
    --relative-path models/clip \
    --filename 'qwen_3_4b.safetensors' && break; \
    if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; \
    SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; \
    done

# 3. Download Diffusion Model (Target: models/unet to match UNETLoader)
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do \
    HF_TOKEN=$HF_TOKEN comfy model download \
    --url 'https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors' \
    --relative-path models/unet \
    --filename 'z_image_turbo_bf16.safetensors' && break; \
    if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; \
    SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; \
    done
