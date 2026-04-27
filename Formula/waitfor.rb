# To install: tap this repository, then install the formula
#   brew tap mlevin2/waitfor https://github.com/mlevin2/waitfor
#   brew install mlevin2/waitfor/waitfor
# For a versioned, checksum-based stable install, add a git tag and extend this
# formula with url + sha256 to the source archive for that tag.
class Waitfor < Formula
  desc "Wait for process(es) by PID or ps match, then optionally run a command"
  homepage "https://github.com/mlevin2/waitfor"
  license "MIT"
  head "https://github.com/mlevin2/waitfor.git", branch: "main"

  depends_on "ripgrep"

  def install
    libexec.install "waitfor" => "waitfor", "tools" => "tools"
    (libexec/"waitfor").chmod(0o755)
    bin.install_symlink libexec/"waitfor" => "waitfor"
  end

  def caveats
    "Optional: fzf (for ambiguous process picks), python3 (for --print-completion / install-completion)"
  end

  test do
    out = shell_output("#{bin}/waitfor --help")
    assert_match(/wait for/i, out)
  end
end
