#!/bin/bash

cd ../SOURCES/
rm -f eFa-base-4.0.0.tar.gz
tar czvf eFa-base-4.0.0.tar.gz eFa-base-4.0.0
cd ../SPECS
rpmbuild -ba eFa4-base.spec
