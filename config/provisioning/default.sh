#!/bin/bash

# This file will be sourced in init.sh
# Anima Preview3 + ComfyUI workflow provisioning script
# Target image: vastai/comfy:cuda-12.9-auto

#DEFAULT_WORKFLOW="https://..."

set +e

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(
    #"package-1"
    #"package-2"
)

NODES=(
    "https://github.com/Comfy-Org/ComfyUI-Manager"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/alexopus/ComfyUI-Image-Saver"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/willmiao/ComfyUI-Lora-Manager"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
)

# Anima Preview3 workflow is UNET / diffusion_models based, not checkpoint based.
CHECKPOINT_MODELS=(
)

DIFFUSION_MODELS=(
    "https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/diffusion_models/anima-preview3-base.safetensors"
)

LORA_MODELS=(
    "https://huggingface.co/circlestone-labs/Anima/resolve/main/turbo_lora/anima-turbo-lora.safetensors"
    "https://huggingface.co/tianweilin/DMD2/resolve/main/dmd2_sdxl_4step_lora.safetensors"
    "https://huggingface.co/hanzogak/Anima-Comradeship/resolve/main/LoRA/Cosmos-Predict2.5-2B-base-distilled-LoRA.safetensors"
    "https://huggingface.co/Kijai/Cosmos_Tokens/resolve/main/Cosmos-Predict2.5-2B-base-distilled-LoRA.safetensors"
    "https://civitai.com/api/download/models/2879555?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1820705?type=Model&format=SafeTensor"
)

VAE_MODELS=(
    "https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/vae/qwen_image_vae.safetensors"
)

TEXT_ENCODERS=(
    "https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/text_encoders/qwen_3_06b_base.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/fofr/comfyui/resolve/main/upscale_models/4x_foolhardy_Remacri.pth"
)

SAM_MODELS=(
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"
)

ULTRALYTICS_BBOX_MODELS=(
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov9c.pt"
    "https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov9c.pt"
    "https://huggingface.co/Bryan32/Adetailer/resolve/main/Eyeful_v2-Individual.pt"
)

ULTRALYTICS_SEGM_MODELS=(
    "https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11m-seg.pt"
    "https://huggingface.co/adbrasi/wanlotest/resolve/main/ntd11_anime_nsfw_segm_v5-variant1.pt"
)

CONTROLNET_MODELS=(
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_setup_environment

    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/diffusion_models" \
        "${DIFFUSION_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/lora" \
        "${LORA_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/controlnet" \
        "${CONTROLNET_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/vae" \
        "${VAE_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/text_encoders" \
        "${TEXT_ENCODERS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/upscale_models" \
        "${UPSCALE_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/sams" \
        "${SAM_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/ultralytics/bbox" \
        "${ULTRALYTICS_BBOX_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/ultralytics/segm" \
        "${ULTRALYTICS_SEGM_MODELS[@]}"

    provisioning_fix_filenames_and_paths
    provisioning_get_default_workflow
    provisioning_print_end

    # Vast comfy image keeps ComfyUI paused while /.provisioning exists.
    rm -f /.provisioning 2>/dev/null || true
}

function provisioning_setup_environment() {
    export WORKSPACE="${WORKSPACE:-/workspace}"

    cd "$WORKSPACE" || cd /

    # vastai/comfy uses /venv/main, not ai-dock/micromamba.
    if [[ -f /venv/main/bin/activate ]]; then
        source /venv/main/bin/activate
        printf "Activated Python environment: /venv/main\n"
    else
        printf "WARNING: /venv/main/bin/activate not found. Falling back to system python.\n"
    fi

    export PYTHON_BIN="${PYTHON_BIN:-python}"
    export PIP_BIN="${PIP_BIN:-python -m pip}"

    mkdir -p /opt/ComfyUI/custom_nodes
    mkdir -p "${WORKSPACE}/storage/stable_diffusion/models"
}

function pip_install() {
    python -m pip install --no-cache-dir "$@"
}

function provisioning_get_apt_packages() {
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo apt-get update
            sudo apt-get install -y "${APT_PACKAGES[@]}"
        else
            apt-get update
            apt-get install -y "${APT_PACKAGES[@]}"
        fi
    fi
}

function provisioning_get_pip_packages() {
    if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
        pip_install "${PIP_PACKAGES[@]}"
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        dir="${dir%.git}"
        path="/workspace/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"

        if [[ -d "$path" ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull --ff-only ) || true

                if [[ -e "$requirements" ]]; then
                    pip_install -r "$requirements" || true
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive || true

            if [[ -e "$requirements" ]]; then
                pip_install -r "$requirements" || true
            fi
        fi

        if [[ -e "${path}/install.py" ]]; then
            printf "Running install.py for node: %s...\n" "${repo}"
            python "${path}/install.py" || true
        fi
    done
}

function provisioning_get_default_workflow() {
    if [[ -n $DEFAULT_WORKFLOW ]]; then
        workflow_json=$(curl -s "$DEFAULT_WORKFLOW")
        if [[ -n $workflow_json ]]; then
            echo "export const defaultGraph = $workflow_json;" > /opt/ComfyUI/web/scripts/defaultGraph.js
        fi
    fi
}

function provisioning_get_models() {
    if [[ -z $2 ]]; then return 0; fi

    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")

    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"

    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_fix_filenames_and_paths() {
    printf "Fixing filenames and model paths...\n"

    model_root="${WORKSPACE}/storage/stable_diffusion/models"

    checkpoints_dir="${model_root}/checkpoints"
    diffusion_dir="${model_root}/diffusion_models"
    lora_dir="${model_root}/lora"
    vae_dir="${model_root}/vae"
    text_encoder_dir="${model_root}/text_encoders"
    upscale_dir="${model_root}/upscale_models"
    sams_dir="${model_root}/sams"
    ultralytics_dir="${model_root}/ultralytics"
    controlnet_dir="${model_root}/controlnet"

    mkdir -p \
        "$checkpoints_dir" \
        "$diffusion_dir" \
        "$lora_dir" \
        "$vae_dir" \
        "$text_encoder_dir" \
        "$upscale_dir" \
        "$sams_dir" \
        "$ultralytics_dir" \
        "$controlnet_dir" \
        /opt/ComfyUI/models

    # Workflow expects:
    # animaOfficial_preview3Base.safetensors
    # Official HF filename:
    # anima-preview3-base.safetensors
    if [[ -f "${diffusion_dir}/anima-preview3-base.safetensors" && ! -e "${diffusion_dir}/animaOfficial_preview3Base.safetensors" ]]; then
        ln -s "${diffusion_dir}/anima-preview3-base.safetensors" "${diffusion_dir}/animaOfficial_preview3Base.safetensors"
    fi

    # Some nodes use loras instead of lora.
    if [[ ! -e "${model_root}/loras" ]]; then
        ln -s "$lora_dir" "${model_root}/loras"
    fi

    # Expose models under /opt/ComfyUI/models as well.
    provisioning_link_model_dir "$checkpoints_dir" "/opt/ComfyUI/models/checkpoints"
    provisioning_link_model_dir "$diffusion_dir" "/opt/ComfyUI/models/diffusion_models"
    provisioning_link_model_dir "$diffusion_dir" "/opt/ComfyUI/models/unet"
    provisioning_link_model_dir "$lora_dir" "/opt/ComfyUI/models/lora"
    provisioning_link_model_dir "$lora_dir" "/opt/ComfyUI/models/loras"
    provisioning_link_model_dir "$vae_dir" "/opt/ComfyUI/models/vae"
    provisioning_link_model_dir "$text_encoder_dir" "/opt/ComfyUI/models/text_encoders"
    provisioning_link_model_dir "$upscale_dir" "/opt/ComfyUI/models/upscale_models"
    provisioning_link_model_dir "$sams_dir" "/opt/ComfyUI/models/sams"
    provisioning_link_model_dir "$ultralytics_dir" "/opt/ComfyUI/models/ultralytics"
    provisioning_link_model_dir "$controlnet_dir" "/opt/ComfyUI/models/controlnet"

    # Compatibility aliases used by some ComfyUI images.
    if [[ ! -e "${model_root}/ckpt" ]]; then
        ln -s "$checkpoints_dir" "${model_root}/ckpt"
    fi

    if [[ ! -e "${model_root}/unet" ]]; then
        ln -s "$diffusion_dir" "${model_root}/unet"
    fi
}

function provisioning_link_model_dir() {
    src="$1"
    dst="$2"

    mkdir -p "$src"

    if [[ -L "$dst" ]]; then
        return 0
    fi

    if [[ -d "$dst" && -z "$(ls -A "$dst" 2>/dev/null)" ]]; then
        rmdir "$dst" 2>/dev/null || true
    fi

    if [[ ! -e "$dst" ]]; then
        ln -s "$src" "$dst"
    fi
}

function provisioning_print_header() {
    printf "\n##############################################\n"
    printf "#                                            #\n"
    printf "#          Provisioning container            #\n"
    printf "#                                            #\n"
    printf "#         This will take some time           #\n"
    printf "#                                            #\n"
    printf "# Your container will be ready on completion #\n"
    printf "#                                            #\n"
    printf "##############################################\n\n"

    if [[ -n "$DISK_GB_ALLOCATED" && -n "$DISK_GB_REQUIRED" && $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
        printf "WARNING: Your allocated disk size (%sGB) is below the recommended %sGB - Some models may not be downloaded\n" "$DISK_GB_ALLOCATED" "$DISK_GB_REQUIRED"
    fi
}

function provisioning_print_end() {
    printf "\nProvisioning complete: Web UI will start now\n\n"
}

function provisioning_has_valid_hf_token() {
    [[ -n "$HF_TOKEN" ]] || return 1
    url="https://huggingface.co/api/whoami-v2"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json")

    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_has_valid_civitai_token() {
    [[ -n "$CIVITAI_TOKEN" ]] || return 1
    url="https://civitai.com/api/v1/models?hidden=1&limit=1"

    response=$(curl -o /dev/null -s -w "%{http_code}" -X GET "$url" \
        -H "Authorization: Bearer $CIVITAI_TOKEN" \
        -H "Content-Type: application/json")

    if [ "$response" -eq 200 ]; then
        return 0
    else
        return 1
    fi
}

function provisioning_download() {
    url="$1"
    dir="$2"
    auth_token=""

    if [[ -n $HF_TOKEN && $url =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif [[ -n $CIVITAI_TOKEN && $url =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi

    if [[ -n $auth_token ]]; then
        wget \
            --header="Authorization: Bearer $auth_token" \
            -qnc \
            --content-disposition \
            --show-progress \
            -e dotbytes="${3:-4M}" \
            -P "$dir" \
            "$url" || true
    else
        wget \
            -qnc \
            --content-disposition \
            --show-progress \
            -e dotbytes="${3:-4M}" \
            -P "$dir" \
            "$url" || true
    fi
}

provisioning_start
