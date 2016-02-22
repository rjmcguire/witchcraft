
module witchcraft.mixins.fields;

mixin template WitchcraftField()
{
    import witchcraft;

    import std.meta;
    import std.traits;
    import std.variant;

    static class FieldImpl(T, string name) : Field
    {
    private:
        alias member = Alias!(__traits(getMember, T, name));

    public:
        override Variant get(Variant instance) const
        {
            auto i = instance.get!T;

            return Variant(__traits(getMember, i, name));
        }

        @property
        override const(Attribute)[] getAttributes() const
        {
            alias attributes = AliasSeq!(__traits(getAttributes, member));

            auto values = new Attribute[attributes.length];

            foreach(index, attribute; attributes)
            {
                values[index] = new AttributeImpl!attribute;
            }

            return values;
        }

        override const(Type) getDeclaringType() const
        {
            alias Parent = Alias!(__traits(parent, member));

            static if(__traits(hasMember, Parent, "classof"))
            {
                return Parent.classof;
            }
            else
            {
                return null;
            }
        }

        override const(TypeInfo) getDeclaringTypeInfo() const
        {
            alias Parent = Alias!(__traits(parent, member));

            static if(__traits(compiles, typeid(Parent)))
            {
                return typeid(Parent);
            }
            else
            {
                return null;
            }
        }

        @property
        override string getName() const
        {
            return name;
        }

        override string getFullName() const
        {
            return fullyQualifiedName!member;
        }

        override string getProtection() const
        {
            return __traits(getProtection, __traits(getMember, T, name));
        }

        override const(Type) getValueType() const
        {
            static if(__traits(hasMember, typeof(member), "classof"))
            {
                return typeof(member).classof;
            }
            else
            {
                return null;
            }
        }

        override const(TypeInfo) getValueTypeInfo() const
        {
            return typeid(typeof(member));
        }

        @property
        override bool isStatic() const
        {
            return __traits(compiles, {
                auto value = __traits(getMember, T, name);
            });
        }

        override void set(Variant instance, Variant value) const
        {
            auto i = instance.get!T;

            __traits(getMember, i, name) = value.get!(typeof(member));
        }
    }
}