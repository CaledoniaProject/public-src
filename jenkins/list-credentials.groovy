import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey

// set Credentials domain name (null means is it global)
domainName = null

credentialsStore = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]?.getStore()
domain = new Domain(domainName, null, Collections.<DomainSpecification>emptyList())

credentialsStore?.getCredentials(domain).each{	
  	if (it instanceof UsernamePasswordCredentialsImpl) {
  		println("type=user/password")
  	} else if(it instanceof BasicSSHUserPrivateKey) {
  		println("type=ssh")
  	} else {
  		println("type=unknown")
  	}

  	println("id=" + it.id)
  	println("description=" + it.description)
  	println("username=" + it.username)
  	println("password=" + it.password?.getPlainText())
  	println("")
}

return

