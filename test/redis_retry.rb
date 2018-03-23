##
## Redis::Retryable Test
##

HOST         = "127.0.0.1"
PORT         = 6999

assert("Redis.new can reconnect") do
  # 1. Start redis-server
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 2. Redis.new
  r = Redis.new HOST, PORT
  assert_equal "PONG", r.ping

  # 3. Stop and Start redis-server
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 4. Recconect
  assert_equal "PONG", r.ping

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
end
