# Getting Started

Install Docker & Docker Compose V2

- https://docs.docker.com/engine/
- https://docs.docker.com/compose/install/

Build the containers & Install libraries

```sh
source env.sh
build
bundle install
yarn install
```

`bundle install` and `yarn install` should also be ran when updating Gem or Node packages.

API tokens and passwords are encrypted before git commit and should be decrypted during development. Decrypted files should not be committed.

To decrypt these secrets:

```
bundle exec thor credentials:decrypt
```

(Decrypted files are gitignored)

Then you can prepare a database.
```sh
rake db:create
rake ridgepole:apply db:seed db:seed_fu
```

## Development environment
Since this project is typed by Sorbet, you will be able to develop comfortably with Ruby-LSP installed. So, we recommend installing the Ruby extension pack from Shopify.

https://marketplace.visualstudio.com/items?itemName=Shopify.ruby-extensions-pack

And disable any other Ruby VSCode extensions, Solargraph, etc.

To perform a type check, execute one of the following commands:

```sh
bundle exec srb tc

# you can use auto-correct
bundle exec srb tc -a

# simpler output
bundle exec spoom tc
```

# Running rails
Load the environment variables into your current shell.

```sh
source env.sh
```

Then `up` will start all containers.

```sh
up
```

Don't mix another project's environment.

## Rails console
```sh
rails c
```

# Testing & Linting
Since the test database will run on tmpfs for performance reason, the database must be prepared for each startup before running rspec.

```sh
# Update DB of test environment (first time and when needed)
rake db:create db:structure:load RAILS_ENV=test
# If DB is to be updated again, the test environment DB must be dropped before doing so (since structure.sql does not have a force option).
rake db:drop RAILS_ENV=test
# run test
rspec
# Example of running only specific tests
rspec spec/path/to/spec.rb
# Can be executed by specifying a line number
rspec spec/path/to/spec.rb:33

# Lint
rubocop
# Auto-correcting
rubocop -A
```

Run rubocop and rspec before committing.

# Typing with sorbet
Ruby files should be type-annotated. But you don't need annotate under these directories:

- 'app/controllers'
- 'app/helpers'
- 'config'
- 'db'

You should always type model scripts, service scripts and scripts under lib directory.

Typing of concern/helper scripts (which are included from another script) may be little bit hard, so you can `typed: false` for these scripts.

## Generating RBIs
After **installing or updating gems**, you need to run this:
- `bundle exec tapioca gem`
- `bundle exec tapioca dsl` (You probably only need to run this if you’ve updated Tapioca)
After running **database migrations**
- `bundle exec tapioca dsl`
After updating the **routes file**
- `bundle exec tapioca dsl`

## Check Gems & DSLs are typed
To ensure all RBI files for DSLs are up-to-date with the latest changes in your application or database, run these commands before commit.

```
bundle exec tapioca gems --verify
bundle exec tapioca dsl --verify
```

These commands checks that RBIs are kept updated or not, and if not, the command shows you to how to update.

## How to type
- https://sorbet.org/docs/sigs

# Rules
Basically, follow the rules of rubocop. You should follow the rules below also which cannot be restricted by rubocop.

## Naming Convention
https://twogate.notion.site/9b6a922dc60f41819bf845e9dcf2493b

## Ordering model associations
Associations order should be:

- `belongs_to`
- `has_one` / `has_many`
- `has_one through` / `has_many through`

Arrange by column name in alphabetical order. (However, columns with strong relationships may be ignored in exceptional cases.)

## Ordering table schema
To create a table for the scope of a tenant, the first column should be `tenant_id`. The last column should be timestamps.

## Do/Don'ts
- Don't install unnecessary Gems.
