#!/bin/bash

cd ../SOURCES/
rm -f eFa-4.0.5.tar.gz
tar czvf eFa-4.0.5.tar.gz eFa-4.0.5
cd ../SPECS
rpmbuild -ba eFa4.spec
