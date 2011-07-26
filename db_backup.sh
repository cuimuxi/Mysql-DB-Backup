#!/bin/bash

# Copyright 2011 Martin Norling
# 
# This file is part of MySQL-DB-Backup.
# 
# MySQL-DB-Backup is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# MySQL-DB-Backup is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with MySQL-DB-Backup.  If not, see <http://www.gnu.org/licenses/>.

###############################################################################
# Settings                                                                    #
###############################################################################

DATABASES="*"
DBUSER="root"
PASSWD=""
WD="/media/backup/databases"

###############################################################################
# Init                                                                        #
###############################################################################

cd "${WD}"
DATETIME=`date "+%Y-%m-%d_%H%M%S"`
LOGIN="-u ${DBUSER}"
if [[ ${PASSWD} != "" ]]
then 
  LOGIN="${LOGIN} -p${PASSWD}"
fi
  
if [[ ${DATABASES} == "*" ]]
then
  QUERY="SHOW DATABASES;"
  DATABASES=`mysql ${LOGIN} -e "${QUERY}" | sed -e '1d'`
fi

###############################################################################
# Backup                                                                      #
###############################################################################

echo "backing up"
for DB in ${DATABASES}
do
    if [[ ${DB} != "information_schema" ]]
    then
      echo "* ${DB}"
      mysqldump ${LOGIN} ${DB} | sed '$d' > "${DB}_${DATETIME}.sql"
      tar -czf "${DB}_${DATETIME}.tar.gz" "${DB}_${DATETIME}.sql"
      rm "${DB}_${DATETIME}.sql"
    fi
done
echo "done"

exit 0
