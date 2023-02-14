#!/bin/bash

# Helper script to generate hash and salted passwords as per Solr's
# security.json.

function do_sha256() {
  # XXX: sha256sum can't give the raw digest, so let's use OpenSSL.
  openssl dgst -sha256 -binary
}

function do_base64() {
  base64 -w0
}

function do_build() {
  echo $SALT | base64 -d
  echo -n $PASS
}

PASS="${1:?Missing the password value.}"
SALT="${2:-$(dd if=/dev/urandom bs=32 count=1 status=none | do_base64)}"

# They do two rounds of hashing.
# @see https://github.com/apache/lucene-solr/blob/84c90ad2c0218156c840e19a64d72b8a38550659/solr/core/src/java/org/apache/solr/security/Sha256AuthenticationProvider.java#L121-L123
SALTEDHASH="$(do_build | do_sha256 | do_sha256 | do_base64)"
RESULT="$SALTEDHASH $SALT"

if [ -z "$2" ] ; then
  if [ "$RESULT" != "$(bash "$0" "$1" "$SALT")" ]; then
    echo "Salted hash is not correct"
    exit 1
  fi
fi

echo -n "$RESULT"
