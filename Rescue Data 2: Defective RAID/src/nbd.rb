# protocol: https://sourceforge.net/p/nbd/code/ci/master/tree/doc/proto.md
require 'socket'

class NBDServer
  NBD_MAGIC = "NBDMAGIC".b
  NBD_IHAVEOPT = "IHAVEOPT".b
  NBD_REQUEST_MAGIC = 0x25609513
  NBD_REPLY_MAGIC = 0x67446698

  NBD_CMD_READ = 0
  NBD_CMD_WRITE = 1
  NBD_CMD_DISC = 2

  NBD_OPT_EXPORT_NAME = 1

  NBD_FLAG_HAS_FLAGS = 1

  OK = 0
  EPERM = 1
  EIO = 5
  ENOMEM = 12
  EINVAL = 22
  ENOSPC = 28
  ESHUTDOWN = 108

  class ProtocolError < StandardError
  end

  def initialize(host, port)
    @host = host
    @port = port
  end

  def size
    raise NotImplementedError
  end
  def read(offset, length)
    raise NotImplementedError
  end
  def write(offset, data)
    raise NotImplementedError
  end

  def reply(client, error, handle, data = "")
    client.write([NBD_REPLY_MAGIC, error, handle].pack("NNQ>") + data)
  end

  def handler(client)
    size = self.size
    handshake_flags = 0
    transmission_flags = NBD_FLAG_HAS_FLAGS
    client.write NBD_MAGIC + NBD_IHAVEOPT + [handshake_flags].pack("n")
    client_flags = client.read(4).unpack("N")[0]

    loop do
      magic = client.read(8)
      if magic != NBD_IHAVEOPT then
        return
      end
      option, length = client.read(8).unpack("NN")
      data = client.read(length)
      
      case option
      when NBD_OPT_EXPORT_NAME then
        data = [size, transmission_flags].pack("Q>n") + "\0".b*124
        client.write(data)
        break
      end
    end
    client.flush

    loop do
      sleep 1
      magic = client.read(4).unpack("N")[0]
      if magic != NBD_REQUEST_MAGIC then
        return
      end
      flags, type, handle, offset, length = client.read(24).unpack("nnQ>Q>N")

      case type
      when NBD_CMD_READ then
        error = OK
        data = self.read(offset, length)
        if data.length != length then
          reply(client, EIO, handle)
          raise "Invalid read data length: %d bytes" % data.length
        end
        reply(client, error, handle, data)
      when NBD_CMD_WRITE then
        data = client.read(length)
        error = self.write(offset, data)
        reply(client, error, handle)
      when NBD_CMD_DISC then
        break
      else
        reply(client, EINVAL, handle)
        break
      end
    end
  rescue Errno::ECONNRESET
  ensure
    client.close
  end

  def serve
    server = TCPServer.new @host, @port
    begin
      loop do
        client = server.accept
        handler(client)
      end
    rescue Interrupt
    end
  end
end

class FileNBDServer < NBDServer
  def initialize(host = "localhost", port = 31337)
    @device = nil
    super host, port
  end
  def assign(device)
    @device = File.open(device, "r+b")
  end

  def size
    @device.size
  end
  def read(offset, length)
    @device.seek(offset)
    @device.read(length)
  end
  def write(offset, data)
    @device.seek(offset)
    @device.write(data)
  end
end

if __FILE__ == $0
  nbd = FileNBDServer.new
  file = "/tmp/nbdtest"
  File.binwrite(file, "\0".b * 512 * 64)
  nbd.assign(file)
  nbd.serve
end
