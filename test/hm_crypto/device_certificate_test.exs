defmodule HmCrypto.DeviceCertificateTest do
  use ExUnit.Case
  alias HmCrypto.{DeviceCertificate, Issuer}
  doctest DeviceCertificate

  setup do
    issuer_private_key = Base.decode64!("91bQVmxUXx+e9gv3TyCW6LIToFDdbnr78UBNiUjJS0I=")
    issuer_name = <<116, 101, 115, 116>>

    {:ok, issuer} = Issuer.new(name: issuer_name, private_key: issuer_private_key)

    device_public_key =
      Base.decode64!(
        "uCSnAUVhhADon4MKkzf1HIpcn1QvY/sVY4huSdHcxYXEkoqjfUwe9q+/C5NXNTWwDDTx+iZ5HaZLE17ypVFd8Q=="
      )

    serial_number = Base.decode16!("BD161F8B4A83A81028")
    app_id = Base.decode16!("594353C0C068F76CE6D4DB2E")

    {:ok, dc} =
      DeviceCertificate.new(
        app_id: app_id,
        serial_number: serial_number,
        public_key: device_public_key
      )

    {:ok, device_certificate: dc, issuer: issuer}
  end

  test "sign device certificate", %{device_certificate: dc, issuer: issuer} do
    refute dc.signature
    dc = DeviceCertificate.sign(dc, issuer)
    assert dc.signature
  end

  test "convert device certificate to bin", %{device_certificate: dc, issuer: issuer} do
    dc_bin =
      dc
      |> DeviceCertificate.sign(issuer)
      |> DeviceCertificate.to_bin()

    <<issuer_name::binary-size(4), app_id::binary-size(12), serial_number::binary-size(9),
      public_key::binary-size(64), signature::binary-size(64)>> = dc_bin

    assert issuer_name == issuer.name
    assert app_id == dc.app_id
    assert serial_number == dc.serial_number
    assert public_key == dc.public_key
    assert byte_size(signature) == 64
  end
end
