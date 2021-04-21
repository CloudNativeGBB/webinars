output jumpbox {
	value = {
		public_ip = module.jumpbox.public_ip
		fqdn = module.jumpbox.fqdn
	}
}