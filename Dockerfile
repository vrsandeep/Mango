FROM 84codes/crystal:1.16.3-alpine AS builder

WORKDIR /Mango

RUN apk add --no-cache yarn yaml-static sqlite-static libarchive-dev libarchive-static acl-static expat-static zstd-static lz4-static bzip2-static libjpeg-turbo-dev libpng-dev tiff-dev cmake

COPY . .

RUN make static || make static

FROM library/alpine

WORKDIR /

COPY --from=builder /Mango/mango /usr/local/bin/mango

CMD ["/usr/local/bin/mango"]
