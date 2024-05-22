class Mesheryctl < Formula
  desc "Command-line utility for Meshery, the cloud native management plane"
  homepage "https://meshery.io"
  url "https://github.com/meshery/meshery.git",
      tag:      "v0.7.61",
      revision: "f758f733b445262863ccbc77de7aaf8705b31d20"
  license "Apache-2.0"
  head "https://github.com/meshery/meshery.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "da7785b54ce86d4a51b17d41c0dbe58e510c64fd8018d1bb7f696b0c8ae09d15"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "da7785b54ce86d4a51b17d41c0dbe58e510c64fd8018d1bb7f696b0c8ae09d15"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "da7785b54ce86d4a51b17d41c0dbe58e510c64fd8018d1bb7f696b0c8ae09d15"
    sha256 cellar: :any_skip_relocation, sonoma:         "261d17bd47f130282bf59bd082d2fc4658329e7e2ce9951d8f28f82c99b9e67b"
    sha256 cellar: :any_skip_relocation, ventura:        "261d17bd47f130282bf59bd082d2fc4658329e7e2ce9951d8f28f82c99b9e67b"
    sha256 cellar: :any_skip_relocation, monterey:       "261d17bd47f130282bf59bd082d2fc4658329e7e2ce9951d8f28f82c99b9e67b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "40013c8d9690864182e4e8b385f2e211872b59947113fc5967d17e1bbf876fa4"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"

    ldflags = %W[
      -s -w
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.version=v#{version}
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.commitsha=#{Utils.git_short_head}
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.releasechannel=stable
    ]

    system "go", "build", *std_go_args(ldflags:), "./mesheryctl/cmd/mesheryctl"

    generate_completions_from_executable(bin/"mesheryctl", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mesheryctl version 2>&1")
    assert_match "Channel: stable", shell_output("#{bin}/mesheryctl system channel view 2>&1")

    # Test kubernetes error on trying to start meshery
    assert_match "The Kubernetes cluster is not accessible.", shell_output("#{bin}/mesheryctl system start 2>&1", 1)
  end
end
