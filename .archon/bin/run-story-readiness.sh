#!/bin/bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <repo-root> <story-number> <artifacts-dir>" >&2
  exit 1
fi

repo_root="$1"
story_num="$2"
artifacts_dir="$3"

wrapper="$repo_root/.archon/bin/claude-omlx-wrapper.sh"
status_dir="$repo_root/.archon/story-status/$story_num"
story_path="$(find "$repo_root/user-stories" -maxdepth 1 -type f | sort | grep "/${story_num}[-_]" | head -1 || true)"
profile_path="$repo_root/docs/quality/story-contract-profile.md"

if [[ -z "$story_path" || ! -f "$story_path" ]]; then
  echo "Could not find local story file for story #$story_num under user-stories/." >&2
  exit 1
fi

mkdir -p "$artifacts_dir" "$status_dir"

if [[ ! -f "$profile_path" ]]; then
  cat > "$profile_path" <<'EOF'
# Story Contract Quality Profile

Use a general approval-biased readiness review.
EOF
fi

cp "$story_path" "$artifacts_dir/story.md"
printf '%s\n' "$story_num" > "$artifacts_dir/story-number"
printf '%s\n' "$story_path" > "$artifacts_dir/story-path"
cp "$profile_path" "$artifacts_dir/story-contract-profile.md"

json_schema='{
  "type": "object",
  "properties": {
    "story_number": { "type": "integer" },
    "story_title": { "type": "string" },
    "verdict": { "type": "string", "enum": ["ready-for-dev", "needs-clarification"] },
    "summary": { "type": "string" },
    "blocking_questions": { "type": "array", "items": { "type": "string" } },
    "strengths": { "type": "array", "items": { "type": "string" } },
    "next_step": { "type": "string" },
    "story_review_md": { "type": "string" },
    "story_contract_md": { "type": "string" },
    "definition_of_done_md": { "type": "string" }
  },
  "required": [
    "story_number",
    "story_title",
    "verdict",
    "summary",
    "blocking_questions",
    "strengths",
    "next_step",
    "story_review_md",
    "story_contract_md",
    "definition_of_done_md"
  ],
  "additionalProperties": false
}'

prompt_file="$(mktemp)"
output_json="$(mktemp)"
parsed_json="$(mktemp)"
trap 'rm -f "$prompt_file" "$output_json" "$parsed_json"' EXIT

cat > "$prompt_file" <<EOF
Review exactly one local markdown user story for implementation readiness.

Story number: $story_num

Review stance:
- Be approval-biased, not criticism-biased.
- Approve stories that are clear enough for a competent engineer to implement and verify.
- Do not search for minor improvements just to have something to criticize.
- Mark "needs-clarification" only when a material ambiguity would force the implementer to guess about core behavior, scope, verification, or data safety.

Return valid JSON only. No markdown fences. No extra commentary.

The JSON fields must be:
- story_number
- story_title
- verdict
- summary
- blocking_questions
- strengths
- next_step
- story_review_md
- story_contract_md
- definition_of_done_md

Rules for markdown fields:
- story_review_md must contain: Verdict, rationale, blocking questions if any, and next step.
- story_contract_md must contain: frozen story title, actor, goal, testable acceptance criteria, and explicit out-of-scope list.
- definition_of_done_md must contain: feature behavior criteria, test/verification criteria, and safety/scope criteria.

Quality profile:
$(cat "$profile_path")

Story markdown:
$(cat "$story_path")
EOF

"$wrapper" \
  --bare \
  --permission-mode bypassPermissions \
  --model Qwen3.5-9B-OptiQ-4bit \
  --output-format json \
  --json-schema "$json_schema" \
  --print "$(cat "$prompt_file")" < /dev/null > "$output_json"

jq -r '.result' "$output_json" | jq '.' > "$parsed_json"

jq '.' "$parsed_json" > "$artifacts_dir/story-review.json"
jq -r '.story_review_md' "$parsed_json" > "$artifacts_dir/story-review.md"
jq -r '.story_contract_md' "$parsed_json" > "$artifacts_dir/story-contract.md"
jq -r '.definition_of_done_md' "$parsed_json" > "$artifacts_dir/definition-of-done.md"

cp "$artifacts_dir/story.md" "$status_dir/story.md"
cp "$artifacts_dir/story-review.json" "$status_dir/story-review.json"
cp "$artifacts_dir/story-review.md" "$status_dir/story-review.md"
cp "$artifacts_dir/story-contract.md" "$status_dir/story-contract.md"
cp "$artifacts_dir/definition-of-done.md" "$status_dir/definition-of-done.md"
jq -r '.verdict' "$parsed_json" > "$status_dir/verdict.txt"

cat > "$status_dir/summary.md" <<EOF
# Local Story Readiness

Story: #$story_num
Verdict: $(cat "$status_dir/verdict.txt")

$(cat "$status_dir/story-review.md")
EOF

cat "$status_dir/summary.md"
