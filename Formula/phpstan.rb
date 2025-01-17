class Phpstan < Formula
  desc "PHP Static Analysis Tool"
  homepage "https://github.com/phpstan/phpstan"
  url "https://github.com/phpstan/phpstan/releases/download/1.8.4/phpstan.phar"
  sha256 "7e496ab046bb476c67f8374c327a39913d8f36b933ce0d0a0dc29f9bae8aaf4e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "8b73212bba7a8d8538719a7a94ef6044b848398c77eae9a767ee584d3ccb526d"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "8b73212bba7a8d8538719a7a94ef6044b848398c77eae9a767ee584d3ccb526d"
    sha256 cellar: :any_skip_relocation, monterey:       "4803034ddcfcf7da680236b979b11e48fc26334fc7ca91ad16d142952dfb8b33"
    sha256 cellar: :any_skip_relocation, big_sur:        "4803034ddcfcf7da680236b979b11e48fc26334fc7ca91ad16d142952dfb8b33"
    sha256 cellar: :any_skip_relocation, catalina:       "4803034ddcfcf7da680236b979b11e48fc26334fc7ca91ad16d142952dfb8b33"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8b73212bba7a8d8538719a7a94ef6044b848398c77eae9a767ee584d3ccb526d"
  end

  depends_on "php" => :test

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "phpstan.phar" => "phpstan"
  end

  test do
    (testpath/"src/autoload.php").write <<~EOS
      <?php
      spl_autoload_register(
          function($class) {
              static $classes = null;
              if ($classes === null) {
                  $classes = array(
                      'email' => '/Email.php'
                  );
              }
              $cn = strtolower($class);
              if (isset($classes[$cn])) {
                  require __DIR__ . $classes[$cn];
              }
          },
          true,
          false
      );
    EOS

    (testpath/"src/Email.php").write <<~EOS
      <?php
        declare(strict_types=1);

        final class Email
        {
            private string $email;

            private function __construct(string $email)
            {
                $this->ensureIsValidEmail($email);

                $this->email = $email;
            }

            public static function fromString(string $email): self
            {
                return new self($email);
            }

            public function __toString(): string
            {
                return $this->email;
            }

            private function ensureIsValidEmail(string $email): void
            {
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    throw new InvalidArgumentException(
                        sprintf(
                            '"%s" is not a valid email address',
                            $email
                        )
                    );
                }
            }
        }
    EOS
    assert_match(/^\n \[OK\] No errors/,
      shell_output("#{bin}/phpstan analyse --level max --autoload-file src/autoload.php src/Email.php"))
  end
end
