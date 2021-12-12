# Create an Azure VPN Gateway
# Set up variables you'll use to create a virtual network
$VNetName  = "VNetData"
$FESubName = "FrontEnd"
$BESubName = "Backend"
$GWSubName = "GatewaySubnet"
$VNetPrefix1 = "192.168.0.0/16"
$VNetPrefix2 = "10.254.0.0/16"
$FESubPrefix = "192.168.1.0/24"
$BESubPrefix = "10.254.1.0/24"
$GWSubPrefix = "192.168.200.0/26"
$VPNClientAddressPool = "172.16.201.0/24"
$ResourceGroup = "VpnGatewayDemo"
$Location = "East US"
$GWName = "VNetDataGW"
$GWIPName = "VNetDataGWPIP"
$GWIPconfName = "gwipconf"

# Create a resource group
New-AzResourceGroup -Name $ResourceGroup -Location $Location

# Create subnet configurations for the virtual network
$fesub = New-AzVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
$besub = New-AzVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
$gwsub = New-AzVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix

# Create the virtual network using the subnet values and a static DNS server
New-AzVirtualNetwork -Name $VNetName `
-ResourceGroupName $ResourceGroup `
-Location $Location `
-AddressPrefix $VNetPrefix1,$VNetPrefix2 `
-Subnet $fesub, $besub, $gwsub `
-DnsServer 10.2.1.3

# Specify the variables for this network that you have just created
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $GWSubName -VirtualNetwork $vnet

# Request a dynamically assigned public IP address
$pip = New-AzPublicIpAddress -Name $GWIPName -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

# Create the VPN gateway
New-AzVirtualNetworkGateway -Name $GWName -ResourceGroupName $ResourceGroup `
-Location $Location -IpConfigurations $ipconf -GatewayType Vpn `
-VpnType RouteBased -EnableBgp $false -GatewaySku VpnGw1 -VpnClientProtocol "IKEv2"

# Add the VPN client address pool
$Gateway = Get-AzVirtualNetworkGateway -ResourceGroupName $ResourceGroup -Name $GWName
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $Gateway -VpnClientAddressPool $VPNClientAddressPool

# Generate a client certificate
# Create the self-signed root certificate
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=P2SRootCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

# Generate a client certificate signed by your new root certificate
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

<# With our certificates generated, we need to export our root certificate's public key.
Run certmgr from PowerShell to open the Certificate Manager.
Go to Personal > Certificates.
Right-click the P2SRootCert certificate in the list, and select All tasks > Export.
In the Certificate Export Wizard, select Next.
Ensure that No, do not export the private key is selected, and then select Next.
On the Export File Format page, ensure that Base-64 encoded X.509 (.CER) is selected, and then select Next.
In the File to Export page, under File name, navigate to a location you'll remember, 
    and save the file as P2SRootCert.cer, and then select Next.
On the Completing the Certificate Export Wizard page, select Finish.
On the Certificate Export Wizard message box, select OK. #>

# Declare a variable for the certificate name
$P2SRootCertName = "P2SRootCert.cer"

# Replace the <cert-path> placeholder with the export location of your root certificate, and run the following command
$filePathForCert = "<cert-path>\P2SRootCert.cer"
$cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
$CertBase64 = [system.convert]::ToBase64String($cert.RawData)
$p2srootcert = New-AzVpnClientRootCertificate -Name $P2SRootCertName -PublicCertData $CertBase64

# Upload the certificate to Azure
Add-AzVpnClientRootCertificate `
-VpnClientRootCertificateName $P2SRootCertName `
-VirtualNetworkGatewayname $GWName `
-ResourceGroupName $ResourceGroup `
-PublicCertData $CertBase64

# Create VPN client configuration files in .ZIP format
$profile = New-AzVpnClientConfiguration -ResourceGroupName $ResourceGroup -Name $GWName -AuthenticationMethod "EapTls"
$profile.VPNProfileSASUrl

<# Copy the URL returned in the output from this command, and paste it into your browser. Your browser should start 
    downloading a .ZIP file. Extract the archive contents and put them in a suitable location.
Some browsers will initially attempt to block downloading this ZIP file as a dangerous download. You will need to 
    override this in your browser to be able to extract the archive contents.
In the extracted folder, navigate to either the WindowsAmd64 folder (for 64-bit Windows computers) or the 
    WindowsX86 folder (for 32-bit computers).
If you want to configure a VPN on a non-Windows machine, you can use the certificate and settings files from the Generic folder.
Double-click the VpnClientSetup{architecture}.exe file, with {architecture} reflecting your architecture.
In the Windows protected your PC screen, select More info, and then select Run anyway.
In the User Account Control dialog box, select Yes.
In the VNetData dialog box, select Yes. #>

<# Press the Windows key, enter Settings, and press kbd>Enter.
In the Settings window, select Network and Internet.
In the left-hand pane, select VPN.
In the right-hand pane, select VNetData, and then select Connect.
In the VNetData window, select Connect.
In the next VNetData window, select Continue.
In the User Account Control message box, select Yes. #>

<# In a new Windows command prompt, run IPCONFIG /ALL.
Copy the IP address under PPP adapter VNetData, or write it down.
Confirm that IP address is in the VPNClientAddressPool range of 172.16.201.0/24.
You have successfully made a connection to the Azure VPN gateway. #>