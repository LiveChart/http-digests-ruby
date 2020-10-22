# HTTP Digest Header

Ruby implementation of [Digest Headers][draft04] draft specification; allows
clients and servers to negotiate an integrity checksum of the exchanged resource
representation data.

### Features

* Verify digests from a `Digest` header containing one or more digests computed with different algorithms,
optionally preferring specific algorithms.

* Generate `Want-Digest` header values with optional `q` values.

### Verifying a signed message

```rb
wanted_digests = HttpDigestHeader::WantedDigestList.build do |builder|
  builder.add("sha-256", 1)
end

verifier = HttpDigestHeader::Verifier.new(wanted_digests)

# Digest string: "sha-256=[base64digest],sha-512=[base64digest]"
verifier.verify!(digest_string, actual_content)
```

### Generate a `Want-Digest` header value

```rb
wanted_digests = HttpDigestHeader::WantedDigestList.build do |builder|
  builder.add("sha-512")
  builder.add("sha-256", 0.5)
end

wanted_digests.to_s # sha-512, sha-256;q=0.5
```


## Contributing

Pull Requests are welcome.


[draft04]: https://tools.ietf.org/html/draft-ietf-httpbis-digest-headers-04
