# typed: true
# frozen_string_literal: true

# Monkey patch to ensure deterministic column order in RBI files
# This fixes CI failures caused by different column orders between local and CI databases
# See: https://github.com/dotnet/efcore/issues/2272 (similar issue in EF Core)
#
# twogate/tapioca fork uses `constant.column_names` to generate `where` method
# keyword arguments, which depends on database column order.
# This patch sorts column_names alphabetically to ensure consistent RBI output.

module TapiocaColumnOrderPatch
  def column_names
    super.sort
  end
end

ActiveRecord::ModelSchema::ClassMethods.prepend(TapiocaColumnOrderPatch)
