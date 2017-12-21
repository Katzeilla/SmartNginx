#! /bin/bash

if [[ $2 == gen_initial_conf ]]; then
  gen_initial_conf
  gen_cert
  gen_conf
  install_cert
else
  gen_cert
  install_cert
fi

gen_initial_conf()
{

}

gen_cert()
{

}

gen_conf()
{

}

install_cert()
{

}
