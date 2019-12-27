#!/bin/bash

cd ../SOURCES/
rm -f eFa-4.0.1.tar.gz
tar czvf eFa-4.0.1.tar.gz eFa-4.0.1
cd ../SPECS
rpmbuild -ba eFa4.spec
