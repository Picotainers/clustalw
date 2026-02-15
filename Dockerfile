# syntax=docker/dockerfile:1
# Compatibility-first template for clustalw.
# Installs package from Bioconda and copies the full conda runtime to avoid missing libs/interpreters.

FROM mambaorg/micromamba:2.0.5-debian12-slim AS builder

RUN micromamba install -y -n base -c conda-forge -c bioconda \
    clustalw \
    && micromamba clean --all --yes

# Resolve a runnable command for this package.
# Prefer exact match, then underscore variant, then prefix match.
RUN set -eux; \
    BIN=""; \
    if [ -x "/opt/conda/bin/clustalw" ]; then BIN="/opt/conda/bin/clustalw"; fi; \
    if [ -z "$BIN" ]; then CAND="/opt/conda/bin/$(echo clustalw | tr '-' '_')"; [ -x "$CAND" ] && BIN="$CAND" || true; fi; \
    if [ -z "$BIN" ]; then BIN="$(find /opt/conda/bin -maxdepth 1 -type f -perm -111 -name 'clustalw*' | head -n1 || true)"; fi; \
    test -n "$BIN"; \
    cp -f "$BIN" /tmp/tool-entry && chmod +x /tmp/tool-entry

FROM mambaorg/micromamba:2.0.5-debian12-slim

COPY --from=builder /opt/conda /opt/conda
COPY --from=builder /tmp/tool-entry /usr/local/bin/clustalw

ENV PATH="/opt/conda/bin:${PATH}"
WORKDIR /data
ENTRYPOINT ["/usr/local/bin/clustalw"]
