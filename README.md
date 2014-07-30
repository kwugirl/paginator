# Pagination Example Template

Set-up:

``` bash
git clone https://github.com/brandur/pagination-template
gem install foreman
bundle install
foreman run
```

To edit the application being run:

```
vi app.rb
```

## Database

Optionally, get the database bootstrapped with the following:

``` bash
brew install postgres # or as applicable for system
createdb pagination-template
```

To access the newly created database:

```
psql pagination-template
```
