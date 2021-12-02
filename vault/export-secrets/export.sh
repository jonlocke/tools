export PYTHONIOENCODING=utf-8
export TOP_VAULT_PREFIX=/users/

./vault-dump.py | tee $(date +%m.%d.%h.%m.%Y.%S)-output.sh
