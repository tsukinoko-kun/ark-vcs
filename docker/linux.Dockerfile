FROM alpine:3.22 AS download
ARG VERSION
RUN : "${VERSION:?build arg VERSION is required, e.g. --build-arg VERSION=1.1.3}" \
 && wget -qO ark.zip "https://www.ark-vcs.com/static/versions/Ark-Vcs_$(echo "$VERSION" | tr . _)_linux.zip" \
 && unzip -j ark.zip "*/ark-cli" -d /out \
 && mkdir /data

FROM gcr.io/distroless/cc-debian13:nonroot
COPY --from=download /out/ark-cli /ark-cli
COPY --from=download --chown=nonroot:nonroot /data /data
EXPOSE 9000
STOPSIGNAL SIGINT
ENTRYPOINT ["/ark-cli"]
CMD ["server", "-path", "/data"]
