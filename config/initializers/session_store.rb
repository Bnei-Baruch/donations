# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_donations_23_session',
  :secret      => '0ed7bb783c140221d330a439fda59454f4f453ae6eed13cee04c803b2c886f2940010dd73fd1ced41e185fe54937b24e88a6806e8305d29ae3ad5a29480d8ec7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
