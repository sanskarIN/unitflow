.PHONY: rust-check rust-test flutter-get flutter-analyze flutter-test test

rust-check:
	cargo check --manifest-path rust/Cargo.toml --all-targets

rust-test:
	cargo test --manifest-path rust/Cargo.toml

flutter-get:
	cd app && flutter pub get

flutter-analyze:
	cd app && flutter analyze

flutter-test:
	cd app && flutter test

test: rust-check rust-test flutter-get flutter-analyze flutter-test
