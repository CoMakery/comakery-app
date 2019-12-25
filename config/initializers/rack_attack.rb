### Throttle all requests by IP (10000rpm)

# Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
Rack::Attack.throttle('req/ip', limit: 10000, period: 1.minute) do |req|
  req.ip
end

### Prevent Brute-Force Login Attacks ###

# The most common brute-force login attack is a brute-force password
# attack where an attacker simply tries a large number of emails and
# passwords to see if any credentials match.
#
# Another common method of attack is to use a swarm of computers with
# different IPs to try brute-forcing a password for a specific account.

# Throttle POST requests to /login by IP address
#
# Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
Rack::Attack.throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
  if req.path == '/session/sign_in' && req.post?
    req.ip
  end
end

### Throttle POST requests to /login by email param

# Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
#
# Note: This creates a problem where a malicious user could intentionally
# throttle logins for another user and force their login requests to be
# denied, but that's not very common and shouldn't happen to you. (Knock
# on wood!)
Rack::Attack.throttle("logins/email", limit: 5, period: 20.seconds) do |req|
  if req.path == '/session/sign_in' && req.post?
    # return the email if present, nil otherwise
    req.params['email'].presence
  end
end

### Throttle API requests by IP (1000rpm)
Rack::Attack.throttle('api/ip', limit: 1000, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api')
end

# Rack::Attack.throttled_response_retry_after_header = true
