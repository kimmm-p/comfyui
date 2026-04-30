#!/bin/bash

# This file will be sourced in init.sh
# https://raw.githubusercontent.com/ai-dock/comfyui/main/config/provisioning/default.sh

#DEFAULT_WORKFLOW="https://..."

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(
    #"package-1"
    #"package-2"
)

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/cubiq/ComfyUI_essentials"

    # Workflow required / strongly related
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/alexopus/ComfyUI-Image-Saver"
    "https://github.com/zanllp/ComfyUI-LoraManager"

    # Optional / existing
    "https://github.com/Toraong/comfyui-instant-lora"
    "https://github.com/shadowcz007/comfyui-mixlab-nodes"
    "https://github.com/city96/ComfyUI-GGUF"
)

CHECKPOINT_MODELS=(
    "https://civitai.red/api/download/models/2883731?type=Model&format=SafeTensor&size=pruned&fp=fp16"
    "https://civitai.com/api/download/models/2765355?type=Model&format=SafeTensor"
)

UNET_MODELS=(
    "https://huggingface.co/circlestone-labs/Anima/resolve/main/split_files/diffusion_models/anima-preview3-base.safetensors"
)

LORA_MODELS=(
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
    "https://huggingface.co/Kim2091/2x-AnimeSharpV4/resolve/main/2x-AnimeSharpV4_Fast_RCAN_PU.safetensors"
)

SAM_MODELS=(
    "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"
)

ULTRALYTICS_BBOX_MODELS=(
    "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov9c.pt"
    "https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov9c.pt"
    "https://huggingface.co/adbrasi/wanlotest/resolve/main/Eyeful_v2-Individual.pt"
)

ULTRALYTICS_SEGM_MODELS=(
    "https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11m-seg.pt"
    "https://huggingface.co/adbrasi/wanlotest/resolve/main/ntd11_anime_nsfw_segm_v5-variant1.pt"
)

CONTROLNET_MODELS=(
)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    if [[ ! -d /opt/environments/python ]]; then
        export MAMBA_BASE=true
    fi

    source /opt/ai-dock/etc/environment.sh
    source /opt/ai-dock/bin/venv-set.sh comfyui

    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/ckpt" \
        "${CHECKPOINT_MODELS[@]}"

    provisioning_get_models \
        "${WORKSPACE}/storage/stable_diffusion/models/unet" \
        "${UNET_MODELS[@]}"

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
        "${WORKSPACE}/storage/stable_diffusion/models/esrgan" \
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
    provisioning_print_end
}

function pip_install() {
    if [[ -z $MAMBA_BASE ]]; then
        "$COMFYUI_VENV_PIP" install --no-cache-dir "$@"
    else
        micromamba run -n comfyui pip install --no-cache-dir "$@"
    fi
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
        sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
        pip_install ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        dir="${dir%.git}"
        path="/opt/ComfyUI/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"

        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                    pip_install -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                pip_install -r "${requirements}"
            fi
        fi

        if [[ -e "${path}/install.py" ]]; then
            printf "Running install.py for node: %s...\n" "${repo}"
            if [[ -z $MAMBA_BASE ]]; then
                "$COMFYUI_VENV_PYTHON" "${path}/install.py" || true
            else
                micromamba run -n comfyui python "${path}/install.py" || true
            fi
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
    if [[ -z $2 ]]; then return 1; fi

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

    # Workflow expects: animaOfficial_preview3Base.safetensors
    unet_dir="${WORKSPACE}/storage/stable_diffusion/models/unet"
    if [[ -f "${unet_dir}/anima-preview3-base.safetensors" && ! -f "${unet_dir}/animaOfficial_preview3Base.safetensors" ]]; then
        ln -s "${unet_dir}/anima-preview3-base.safetensors" "${unet_dir}/animaOfficial_preview3Base.safetensors"
    fi

    # Some ComfyUI nodes look for upscale models under upscale_models instead of esrgan.
    esrgan_dir="${WORKSPACE}/storage/stable_diffusion/models/esrgan"
    upscale_dir="${WORKSPACE}/storage/stable_diffusion/models/upscale_models"
    mkdir -p "$upscale_dir"

    if [[ -f "${esrgan_dir}/4x_foolhardy_Remacri.pth" && ! -f "${upscale_dir}/4x_foolhardy_Remacri.pth" ]]; then
        ln -s "${esrgan_dir}/4x_foolhardy_Remacri.pth" "${upscale_dir}/4x_foolhardy_Remacri.pth"
    fi

    if [[ -f "${esrgan_dir}/2x-AnimeSharpV4_Fast_RCAN_PU.safetensors" && ! -f "${upscale_dir}/2x-AnimeSharpV4_Fast_RCAN_PU.safetensors" ]]; then
        ln -s "${esrgan_dir}/2x-AnimeSharpV4_Fast_RCAN_PU.safetensors" "${upscale_dir}/2x-AnimeSharpV4_Fast_RCAN_PU.safetensors"
    fi

    # Also expose models directly under /opt/ComfyUI/models if the image does not symlink them automatically.
    mkdir -p /opt/ComfyUI/models

    for model_subdir in unet lora controlnet vae text_encoders sams ultralytics esrgan upscale_models ckpt; do
        src="${WORKSPACE}/storage/stable_diffusion/models/${model_subdir}"
        dst="/opt/ComfyUI/models/${model_subdir}"

        if [[ -d "$src" && ! -e "$dst" ]]; then
            ln -s "$src" "$dst"
        fi
    done

    # ComfyUI commonly uses checkpoints/upscale_models names.
    if [[ -d "${WORKSPACE}/storage/stable_diffusion/models/ckpt" && ! -e "/opt/ComfyUI/models/checkpoints" ]]; then
        ln -s "${WORKSPACE}/storage/stable_diffusion/models/ckpt" "/opt/ComfyUI/models/checkpoints"
    fi

    if [[ -d "${WORKSPACE}/storage/stable_diffusion/models/esrgan" && ! -e "/opt/ComfyUI/models/upscale_models" ]]; then
        ln -s "${WORKSPACE}/storage/stable_diffusion/models/esrgan" "/opt/ComfyUI/models/upscale_models"
    fi
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"

    if [[ $DISK_GB_ALLOCATED -lt $DISK_GB_REQUIRED ]]; then
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
    auth_token=""

    if [[ -n $HF_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif [[ -n $CIVITAI_TOKEN && $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_TOKEN"
    fi

    if [[ -n $auth_token ]]; then
        wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    else
        wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
    fi
}

provisioning_start
