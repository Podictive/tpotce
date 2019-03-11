# This is the internal user database
# The hash value is a bcrypt hash and can be generated with plugin/tools/hash.sh

#password is: admin... just kidding!
admin:
  readonly: true
  hash: ${bcrypt_adminpassword}
  roles:
    - admin
  attributes:
    #no dots allowed in attribute names
    attribute1: value1
    attribute2: value2
    attribute3: value3

#password is: ${logstashpassword}
logstash:
  hash: ${bcrypt_logstashpassword}
  roles:
    - logstash

#password is: kibanaserver  
kibanaserver:
  readonly: true
  hash: ${bcrypt_kibanapassword}

#password is: kibanaro
kibanaro:  
  hash: ${bcrypt_kibanareadonlypassword}
  roles:
    - kibanauser
    - readall

#password is: readall
readall:
  hash: ${bcrypt_readallpassword}
  #password is: readall
  roles:
    - readall

#password is: snapshotrestore
snapshotrestore:
  hash: ${bcrypt_snapshotrestorepassword}
  roles:
    - snapshotrestore
