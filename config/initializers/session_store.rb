# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_shibwatch_session',
  :secret      => 'f54123d15b1c3c34a6a9122ea25bf3d72a58cfc106cd4d0aa055f9e78996c33eb977d1eaee40fdd65ec13a78bb56c8193d0fdf07decb3b09f201d5a8f58a2e91'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
