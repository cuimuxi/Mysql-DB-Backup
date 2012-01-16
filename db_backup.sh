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
HASH="md5 -q"
WD="./dumps"

###############################################################################
# Init                                                                        #
###############################################################################

VERBOSE="FALSE"

if [ "$1" == "-v" ]
then
  VERBOSE="TRUE"
fi

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

if [ "${VERBOSE}" == "TRUE" ]
then
	echo " == Backing up Databases == "
fi

for DB in ${DATABASES}
do
    if [[ ${DB} != "information_schema" ]]
    then
      mkdir -p ${DB}
	  if [ "${VERBOSE}" == "TRUE" ]
	  then
        printf "> ${DB} "
      fi
      
      # Create database dump
      mysqldump ${LOGIN} ${DB} | sed '$d' > "${DB}_${DATETIME}.sql"
      
      # Check hash towards latest file
      new_hash=`${HASH} ${DB}_${DATETIME}.sql`
      last_file=`ls -rt ${DB} | tail -1`
      old_hash=`${HASH} ${DB}/${last_file} 2>/dev/null`
      
      # Check hashes and store new file if there is a change
      if ! [ "${new_hash}" == "${old_hash}" ]
	  then
	    mv "${DB}_${DATETIME}.sql" "${DB}"
		if [ "${VERBOSE}" == "TRUE" ]
		then
	      echo "[SAVED]"
	    fi
      else
	    rm "${DB}_${DATETIME}.sql"
		if [ "${VERBOSE}" == "TRUE" ]
		then
          echo "[NO CHANGES]"
        fi
	  fi
    fi
done
if [ "${VERBOSE}" == "TRUE" ]
then
  echo " == Done == "
fi

exit 0
