require 'spec_helper'
module Finitio
  describe Syntax, "ad_type" do

    subject{
      Syntax.parse(input, root: "ad_type")
    }

    let(:compiled){
      subject.compile(type_factory)
    }

    let(:ast){
      subject.to_ast
    }

    context 'One contract' do
      let(:input){ '.Color <rgb> {r: .Integer, g: .Integer, b: .Integer}' }

      it 'compiles to an AdType' do
        expect(compiled).to be_a(AdType)
        expect(compiled.ruby_type).to be(Color)
        expect(compiled.contract_names).to eq([:rgb])
      end

      it 'should behave as expected' do
        expect(compiled.dress(r: 138, g: 43, b: 226)).to eq(blueviolet)
      end

      it 'has expected AST' do
        expect(ast).to eq([
          :ad_type,
          "Color",
          [:contract,
            "rgb",
            [:tuple_type,
              [:heading,
                [:attribute, "r", [:builtin_type, "Integer"]],
                [:attribute, "g", [:builtin_type, "Integer"]],
                [:attribute, "b", [:builtin_type, "Integer"]]
              ]
            ]
          ]
        ])
      end

    end

    context 'Two contracts' do
      let(:input){
        <<-TYPE.strip
        .Color <rgb> {r: .Integer, g: .Integer, b: .Integer},
               <hex> .String
        TYPE
      }

      it 'compiles to an AdType' do
        expect(compiled).to be_a(AdType)
        expect(compiled.ruby_type).to be(Color)
        expect(compiled.contract_names).to eq([:rgb, :hex])
      end

      it 'should behave as expected' do
        expect(compiled.dress("#8A2BE2")).to eq(blueviolet)
      end

      it 'has expected AST' do
        expect(ast).to eq([
          :ad_type,
          "Color",
          [:contract,
            "rgb",
            [:tuple_type,
              [:heading,
                [:attribute, "r", [:builtin_type, "Integer"]],
                [:attribute, "g", [:builtin_type, "Integer"]],
                [:attribute, "b", [:builtin_type, "Integer"]]
              ]
            ]
          ],
          [:contract,
            "hex",
            [:builtin_type, "String"]
          ]
        ])
      end
    end

    context 'No ruby class' do
      let(:input){ '<as> {r: .Integer}' }

      it 'compiles to an AdType' do
        expect(compiled).to be_a(AdType)
        expect(compiled.ruby_type).to be_nil
        expect(compiled.contract_names).to eq([:as])
      end

      it 'should behave as expected' do
        expect(compiled.dress(r: 12)).to eq(r: 12)
        expect{
          compiled.dress("foo")
        }.to raise_error(TypeError)
      end

      it 'has expected AST' do
        expect(ast).to eq([
          :ad_type,
          nil,
          [:contract,
            "as",
            [:tuple_type,
              [:heading,
                [:attribute, "r", [:builtin_type, "Integer"]],
              ]
            ]
          ]
        ])
      end
    end

    context 'Duplicate contract name' do
      let(:input){ '.Color <rgb> {r: .Integer}, <rgb> .String' }

      it 'raises an error' do
        expect{
          compiled
        }.to raise_error(Error, "Duplicate contract name `rgb`")
      end
    end

    context 'A contract with explicit converters' do
      let(:input){ '.DateTime <iso> .String \( s | DateTime.parse(s) ) \( d | d.to_s )' }

      it 'compiles to an AdType' do
        expect(compiled).to be_a(AdType)
        expect(compiled.ruby_type).to be(DateTime)
        expect(compiled.contract_names).to eq([:iso])
      end

      it 'should behave as expected' do
        expect(compiled.dress("2014-01-19T12:00")).to be_a(DateTime)
      end

      it 'should hide errors' do
        err = compiled.dress("foo") rescue $!
        expect(err).to be_a(TypeError)
        expect(err.message).to eq("Invalid DateTime `foo`")
      end

      it 'has expected AST' do
        expect(ast).to eq([
          :ad_type,
          "DateTime",
          [:contract,
            "iso",
            [:builtin_type, "String"],
            [:inline_pair,
              [:fn, [:parameters, "s"], [:source, "DateTime.parse(s)"]],
              [:fn, [:parameters, "d"], [:source, "d.to_s"]],
            ]
          ]
        ])
      end

      it 'is equal to itself' do
        j = Syntax.parse(input, root: "ad_type").compile(type_factory)
        expect(j).to eql(compiled)
      end
    end

  end
end
