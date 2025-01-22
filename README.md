# **Script Name**: `rcd-llm-dmenu-launcher.sh`

The rcd-llm-dmenu-launcher.sh script lets you select and launch LLMs via dmenu. It kills any running llama-server, launches the chosen model with its GPU layers (NGL), logs output, and provides audible feedback. A user-friendly LLM manager!

This project is built on top of the amazing [llama.cpp](https://github.com/ggerganov/llama.cpp) project by @ggerganov.

---

## **Purpose**:

The script is designed to manage and launch **Large Language Models (LLMs)** using a user-friendly interface (`dmenu`). It allows you to:

1. **Select a model** from a list of predefined LLM files.
2. **Kill any running instance** of `llama-server` (if one exists).
3. **Launch a new instance** of `llama-server` with the selected model and its corresponding number of GPU layers (`NGL`).

[![LLM Launcher Demo](https://img.youtube.com/vi/y3G1fHkLEaI/0.jpg)](https://www.youtube.com/watch?v=y3G1fHkLEaI)

---

## **Key Features**:

1. **Model Selection**:

   - The script uses `dmenu` to display a list of LLM filenames (without full paths) for selection.
   - The `dmenu` interface is customized with specific styling:
     - Font: `DejaVu` with a pixel size of `24`.
     - Colors: Foreground (`-nf`) is blue, and background (`-nb`) is pink.
     - Behavior: Case-insensitive (`-i`) and displays up to `10` lines (`-l 10`).

2. **Dynamic Model Configuration**:

   - Models and their corresponding `NGL` (Number of GPU Layers) values are stored in an associative array (`MODELS`).
   - Each model is mapped to its full file path and `NGL` value.

3. **Process Management**:

   - The script checks if `llama-server` is already running using `pgrep`.
   - If a running instance is found, it kills the process before launching a new one.

4. **Logging**:

   - The output of `llama-server` is redirected to a log file (`~/tmp/llm.log`) for debugging and monitoring.

5. **User Feedback**:

   - The script uses `espeak` to provide audible feedback when starting a new LLM instance.
   - It also prints the selected model and `NGL` value to the terminal.

---

## **How It Works**:

1. **Model List**:

   - The script defines an associative array (`MODELS`) where each key is the **full path** to an LLM file, and the value is the corresponding `NGL` value.

2. **`dmenu` Selection**:

   - The script extracts the filenames (using `basename`) from the `MODELS` array and displays them in `dmenu`.
   - The user selects a model from the list.

3. **Model Validation**:

   - The script maps the selected filename back to its full path and retrieves the corresponding `NGL` value.

4. **Process Management**:

   - If `llama-server` is already running, the script kills the process using its PID.
   - It then launches a new instance of `llama-server` with the selected model and `NGL` value.

5. **Logging and Feedback**:

   - The script logs the output of `llama-server` to `~/tmp/llm.log`.
   - It provides audible and visual feedback to the user.

---

## **Example Usage**:

1. **Valid Model**:
   ```bash
   ./rcd-llm-dmenu-launcher.sh QwQ-LCoT-3B-Instruct.Q4_K_M.gguf
   ```
   - Output (if model exists):
     ```
     Selected Model: /home/data1/protected/Programming/llamafile/QwQ-LCoT-3B-Instruct.Q4_K_M.gguf
     NGL: 999
     ```

2. **Invalid Model**:
   ```bash
   ./rcd-llm-dmenu-launcher.sh NonExistentModel.gguf
   ```
   - Output:
     ```
     Error: Model 'NonExistentModel.gguf' not found in the list.
     ```

3. **No Model Provided**:
   ```bash
   ./rcd-llm-dmenu-launcher.sh
   ```
   - Displays the `dmenu` interface for model selection.

   A `dmenu` prompt appears with a list of LLM filenames:
   **You are supposed to modify the list of GGUF files yourself within the script!**
   ```
   QwQ-LCoT-3B-Instruct.Q4_K_M.gguf
   Phi-3.5-mini-instruct-Q3_K_M.gguf
   Qwen2.5-1.5B-Instruct-Q4_K_M.gguf
   Dolphin3.0-Qwen2.5-1.5B-Q5_K_M.gguf
   Dolphin3.0-Qwen2.5-3B-Q5_K_M.gguf
   OLMo-2-1124-7B-Instruct-Q3_K_M.gguf
   SmolLM-1.7B-Instruct-Q5_K_M.gguf
   DeepSeek-R1-Distill-Qwen-1.5B-Q5_K_M.gguf
   ```

Simply modify full path for your own models.

4. Select a model (e.g., `QwQ-LCoT-3B-Instruct.Q4_K_M.gguf`).

5. The script:

   - Kills any running `llama-server` instance.
   - Launches a new instance with the selected model and its `NGL` value.
   - Logs the output to `~/tmp/llm.log`.

---

## **Example Output**:

### Terminal Output:
```
Selected Model: /home/data1/protected/Programming/llamafile/QwQ-LCoT-3B-Instruct.Q4_K_M.gguf
NGL: 999
```

### Audible Feedback:
- "Starting Large Language Model with QwQ-LCoT-3B-Instruct.Q4_K_M.gguf"

---

## **Customization**:
1. **Add/Remove Models**:
   - Edit the `MODELS` associative array to include or exclude models.
   - Example:
     ```bash
     declare -A MODELS=(
         ["/path/to/model1.gguf"]=999
         ["/path/to/model2.gguf"]=20
     )
     ```

2. **Change `dmenu` Styling**:
   - Modify the `dmenu` command in the script to adjust font, colors, or behavior.

3. **Log File Location**:
   - Change the `LOG` variable to specify a different log file path.

---

### **Dependencies**:
1. **`dmenu`**:
   - Required for model selection. Install it using your package manager:
     ```bash
     sudo apt install dmenu
     ```

2. **`espeak`**:
   - Used for audible feedback. Install it using:
     ```bash
     sudo apt install espeak
     ```

3. **`llama-server`**:
   - Ensure `llama-server` is installed and accessible in your `$PATH`.

## Integration:

For quick access, bind the script to a key in your Window Manager or add it to a menu. Example for IceWM (~/.icewm/toolbar):
plaintext
```
prog "LLM Model" /usr/share/icons/hicolor/scalable/apps/oregano.svg /home/data1/protected/bin/rcd/rcd-llm-dmenu-launcher.sh
```

## Credits
- [llama.cpp](https://github.com/ggerganov/llama.cpp): Core LLM inference library.
- [dmenu](https://tools.suckless.org/dmenu/): Used for the model selection interface.


---

## **Conclusion**:

The **`rcd-llm-dmenu-launcher.sh`** script is a powerful and user-friendly tool for managing and launching Large Language Models. It combines the flexibility of `dmenu` with robust process management and logging capabilities, making it an excellent choice for LLM workflows.
