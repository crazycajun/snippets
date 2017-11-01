require 'openssl'
require 'base64'

secret = "some secret value like SECRET_KEY_BASE from RAILS"
static_salt = "this should probably be some value"

username_for_password = "mr_test"
password_to_encrypt = "TheGreatestPasswordEver"

key_size_bits = 256

# Create an instance of SHA256 which will be used to HMAC
# In to PBKDF2
sha256 = OpenSSL::Digest::SHA256.new

# Derive the AES key from a secret, a salt, and a digest.
aes_key = OpenSSL::PKCS5.pbkdf2_hmac(secret, static_salt, 250000, key_size_bits / 8, sha256)

# Create an encryption instance.
aes = OpenSSL::Cipher::AES.new(256, :GCM)

# Put us in encrypt mode.
aes.encrypt

# Set the key.
aes.key = aes_key

# Create a Nonce.
# THIS MUST BE UNIQUE FOR EVERY ENCRYPT CALL.
aes.iv = "1234567890AB"

# GCM requires authentication data. This is part of the AEAD behavior of GCM. For this use
# case, it's fine to use an empty string. However the username that the password is associated
# with may be part of the function.
aes.auth_data = username_for_password

# For strings this behavior is fine. If this is ever a huge chuck of data
# check we should chunk the updates.
encrypted = aes.update(password_to_encrypt) + aes.final
tag = aes.auth_tag



puts "This is the encrypted value: " + Base64.encode64(encrypted)
puts "This is the authentication tag: " + Base64.encode64(tag)