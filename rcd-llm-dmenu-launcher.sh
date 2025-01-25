#!/usr/bin/bash -x

# Copyright (C) 2025-01-22 by Jean M. Louis, https://gnu.support

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Define models and their corresponding NGL values
declare -A MODELS=(
    ["/home/data1/protected/Programming/LLM/QwQ-LCoT-3B-Instruct.Q4_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Mistral/quantized/Ministral-3b-instruct-Q4_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Mistral/quantized/Mistral-7B-v0.3-Q4_K_M.gguf"]=20
    ["/home/data1/protected/Programming/LLM/Microsoft/quantized/Phi-3.5-mini-instruct-Q3_K_M.gguf"]=30
    ["/home/data1/protected/Programming/LLM/Qwen/quantized/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Dolphin/quantized/Dolphin3.0-Qwen2.5-1.5B-Q5_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Dolphin/quantized/Dolphin3.0-Qwen2.5-3B-Q5_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/AllenAI/quantized/olmo-2-1124-7B-instruct-Q2_K.gguf"]=24
    ["/home/data1/protected/Programming/LLM/AllenAI/quantized/OLMo-2-1124-7B-Instruct-Q3_K_M.gguf"]=18
    ["/home/data1/protected/Programming/LLM/AllenAI/quantized/olmo-2-1124-7B-instruct-Q3_K_S.gguf"]=21
    ["/home/data1/protected/Programming/LLM/SmolLM/quantized/SmolLM-1.7B-Instruct-Q5_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/DeepSeek/quantized/DeepSeek-R1-Distill-Qwen-1.5B-Q5_K_M.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Qwen/quantized/DeepSeek-R1-Distill-Qwen-7B-Q3_K_S.gguf"]=999
    ["/home/data1/protected/Programming/LLM/Qwen/quantized/DeepSeek-R1-Distill-Qwen-7B-Q3_K_M.gguf"]=25
)

LLAMA_SERVER="/usr/local/bin/llama-server"
LOG="$HOME/tmp/llm.log"

HOST=$(/home/data1/protected/bin/rcd/get_ethernet_interface.sh)

# Get the list of full model paths
model_paths=("${!MODELS[@]}")

# Check if a model name is provided as a command-line argument
if [ -n "$1" ]; then
    selected_model="$1"
    # Verify if the provided model exists in the MODELS array
    MODEL_FOUND=false
    for model_path in "${!MODELS[@]}"; do
        if [[ "$(basename "$model_path")" == "$selected_model" ]]; then
            MODEL_FOUND=true
            break
        fi
    done
    if [ "$MODEL_FOUND" = false ]; then
        echo "Error: Model '$selected_model' not found in the list."
        exit 1
    fi
else
    # Use dmenu to select a model (display only the basename of the file)
    selected_model=$(basename -a "${!MODELS[@]}" | dmenu -fn "DejaVu:pixelsize=24" -l 10 -i -b -p "Select a model:" -nf blue -nb cyan)
fi

# Check if a model was selected
if [ -z "$selected_model" ]; then
    echo "No model selected. Exiting."
    exit 1
fi

# Find the full path of the selected model
MODEL=""
for model_path in "${!MODELS[@]}"; do
    if [[ "$(basename "$model_path")" == "$selected_model" ]]; then
        MODEL="$model_path"
        break
    fi
done

# Check if the model was found
if [ -z "$MODEL" ]; then
    echo "Selected model not found in the list. Exiting."
    exit 1
fi

# Get the NGL value for the selected model
NGL=${MODELS[$MODEL]}

# Kill any running instance of llama-server
PID=$(pgrep -x 'llama-server')
if [ -n "$PID" ]; then
    echo "Killing existing llama-server with PID $PID"
    kill -9 "$PID"
    sleep 1
fi

# Start the new instance of llama-server
MESSAGE="Starting Large Language Model: $(basename "$MODEL")"
espeak "$MESSAGE" &
notify-send "LLM Model" "$MESSAGE" &
echo "Selected Model: $MODEL"
echo "NGL: $NGL"
$LLAMA_SERVER -ngl "$NGL" --host "$HOST" -m "$MODEL" > "$LOG" 2>&1 &
pgrep -a llama-server
sleep 3
firefox-esr "http://$HOST:8080"
