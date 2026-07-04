#!/usr/bin/env bash
input=$(cat)
command=$(echo "$input" | jq -r '.command // empty')
phase="unknown"
if [[ -f .cursor/workflow-phase ]]; then
  phase=$(tr -d '[:space:]' < .cursor/workflow-phase)
fi

if [[ "$command" == *"git push"* ]] && [[ "$phase" == "tdd" || "$phase" == "implement" || "$phase" == "refactor" || "$phase" == "smoke" ]]; then
  cat <<EOF
{
  "permission": "deny",
  "user_message": "Push blocked during $phase phase.",
  "agent_message": "Do not push during $phase. Commit locally only."
}
EOF
  exit 0
fi

cat <<EOF
{"permission": "allow"}
EOF
