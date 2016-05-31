Using ZenCI to deploy entire code for Drupal project, include drupal by itself.
example repo: https://github.com/Zen-CI/drupal/tree/production

1. Fork https://github.com/drupal/drupal
2. Select commit for latest tag release, browser files
3. Create branch based on this tag. Let’s cal it production
4. Enable Zen.ci for this repo
5. Setup user account with database access on deploy target.
6. set .ssh/authorized_keys with 600 permission and write there a public_key for this repo.
7. Create install script to install drupal and store it on server.
I decided to store it in {home}/scripts/drupal_install.sh

```
#!/bin/sh

echo "Installing drupal to " . $DOCROOT

DATABASE_PASS=“REPLACE WITH YOUR DB PASS”
cd $DOCROOT

#link all core files
ln -s $ZENCI_DEPLOY_DIR/* ./
ln -s $ZENCI_DEPLOY_DIR/.htaccess ./

#copy sites directory instead of linking to move it out of git repo
rm -f sites
cp -r $ZENCI_DEPLOY_DIR/sites ./

#Install drupal

drush site-install standard -y --root=$DOCROOT --account-mail=admin@git.lc --uri=http://$DOMAINNAME --site-name=$SITENAME --site-mail=$SITEMAIL --db-url=mysql://$DATABASE_USER:$DATABASE_PASS@localhost/$DATABASE_NAME
```
8. Create .zenci.yml file to deploy code for this branch
```
deploy:
  production:
    server: p1.zen.ci
    username: zen
    dir: '{home}/github/drupal/{branch}'
    env_vars:
      docroot: '{home}/domains/zen.ci'
      domain: zen.ci
      sitename: ZenCI
      sitemail: noreply@zen.ci
      database_name: zen_production
      database_user: zen_production
    scripts:
      init: '{home}/scripts/drupal_install.sh'
```

9. When you push .zenci.yml - it should start deploy and install default drupal site.

[Here](http://git.lc/Zen-CI/drupal/deploy/deploy-Zen-CI_drupal_production-6809) is initial deploy log:
![img1](https://files.gitter.im/itpatrol/itp/mwWy/Screen-Shot-2016-05-31-at-1.40.56-PM.png)

Extra step.
It is very important to process update.php after code update and reset cache.

Let's create script {home}/scripts/drupal_after.sh
```
#!/bin/sh

cd $DOCROOT

drush updb -y
drush cc all
```

Add it to .zenci.yml as after option:
```
deploy:
  production:
    server: p1.zen.ci
    username: zen
    dir: '{home}/github/drupal/{branch}'
    env_vars:
      docroot: '{home}/domains/zen.ci'
      domain: zen.ci
      sitename: ZenCI
      sitemail: noreply@zen.ci
      database_name: zen_production
      database_user: zen_production
    scripts:
      init: '{home}/scripts/drupal_install.sh'
      after: '{home}/scripts/drupal_updb.sh'
```

[Here](http://git.lc/Zen-CI/drupal/deploy/deploy-Zen-CI_drupal_production-6818) is update deploy log:
![img1](https://files.gitter.im/itpatrol/itp/mwWy/Screen-Shot-2016-05-31-at-1.40.44-PM.png)
