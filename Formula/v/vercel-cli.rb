require "language/node"

class VercelCli < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-32.5.1.tgz"
  sha256 "51102232693f6027bfb144d3f3dbc093c87cb18796b95a70f2dda8d7ea733155"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "ed2d9d13c551aea220eedbdcc270e2727776f4f6b0d52e22d884932f4fbbf6c2"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ed2d9d13c551aea220eedbdcc270e2727776f4f6b0d52e22d884932f4fbbf6c2"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ed2d9d13c551aea220eedbdcc270e2727776f4f6b0d52e22d884932f4fbbf6c2"
    sha256 cellar: :any_skip_relocation, sonoma:         "904f8195a8f2ab0bc5a540171e0e260ad67ab18b6b0a02ad17b4692c6785230e"
    sha256 cellar: :any_skip_relocation, ventura:        "904f8195a8f2ab0bc5a540171e0e260ad67ab18b6b0a02ad17b4692c6785230e"
    sha256 cellar: :any_skip_relocation, monterey:       "904f8195a8f2ab0bc5a540171e0e260ad67ab18b6b0a02ad17b4692c6785230e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8d308e7b2305dfea58235ca8503f5d4e9068d139fdbe8b1e142310bbeb96f747"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "${await getUpdateCommand()}",
                               "brew upgrade vercel-cli"
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible deasync modules
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/vercel/node_modules"
    node_modules.glob("deasync/bin/*")
                .each { |dir| dir.rmtree if dir.basename.to_s != "#{os}-#{arch}" }

    # Replace universal binaries with native slices
    (node_modules/"fsevents/fsevents.node").unlink if OS.mac? && Hardware::CPU.arm?
    deuniversalize_machos
  end

  test do
    system "#{bin}/vercel", "init", "jekyll"
    assert_predicate testpath/"jekyll/_config.yml", :exist?, "_config.yml must exist"
    assert_predicate testpath/"jekyll/README.md", :exist?, "README.md must exist"
  end
end
