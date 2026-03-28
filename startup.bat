@echo off
echo Starting Relay + vLLM...
echo.

:: Start vLLM inference server (takes a few minutes to load the model)
start "vLLM Server" wsl -d Ubuntu bash -c "source ~/vllm-env/bin/activate && export NCCL_P2P_DISABLE=1 && export CUDA_VISIBLE_DEVICES=0,1 && vllm serve '/mnt/d/models/vllm_models/Qwen3.5-27B-FP8' --port 8000 --tensor-parallel-size 2 --gpu-memory-utilization 0.88 --max-model-len 32768 --trust-remote-code --reasoning-parser qwen3 --max-num-seqs 128 --disable-log-stats"

:: Start Relay UI file server (adjust path if your relay repo is elsewhere)
start "Relay UI" wsl -d Ubuntu bash -c "cd ~/relay && python3 -m http.server 3000"

echo ----------------------------------------
echo   vLLM Server   http://localhost:8000
echo   Relay UI      http://localhost:3000
echo.
echo   On iPhone (via Tailscale):
echo     http://YOUR-TAILSCALE-IP:3000
echo.
echo   vLLM takes a few minutes to load.
echo   Open Relay once the vLLM window shows
echo   "Application startup complete."
echo ----------------------------------------
echo.
pause
