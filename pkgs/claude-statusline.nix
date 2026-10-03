# Claude Code status line script (host, git, jj change id, model, context
# usage and subscription rate limits). See
# aspects/homeManager/claude.nix, which points ~/.claude/settings.json's
# statusLine at this binary.
#
# jj is deliberately NOT a runtimeInput: the script only shows the jj segment
# when the user's own jj is on PATH, and a pinned copy here could disagree
# with the repo format the user's jj writes.
{
  writeShellApplication,
  coreutils,
  git,
  jq,
}:
writeShellApplication {
  name = "claude-statusline";
  runtimeInputs = [coreutils git jq];
  # Every segment is best-effort and degrades to "omit" on failure, so the
  # default errexit/nounset/pipefail would only turn a missing field into a
  # blank status line.
  bashOptions = [];
  text = builtins.readFile ./claude-statusline.sh;
}
