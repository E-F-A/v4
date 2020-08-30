#!/bin/bash

cd ../SOURCES/
rm -f eFa-4.0.3.tar.gz
tar czvf eFa-4.0.3.tar.gz eFa-4.0.3
cd ../SPECS
rpmbuild -ba eFa4.spec
