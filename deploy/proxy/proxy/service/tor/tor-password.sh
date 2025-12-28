#!/bin/sh

# 1. Generate secure password hash
tor --hash-password "StrongPassword123!"

# 2. Use in torrc
HashedControlPassword 16:GeneratedHashHere

# 3. Set proper permissions
chmod 600 /etc/tor/torrc
chown tor:tor /etc/tor/torrc
