import mongoose from 'mongoose';

const { Schema } = mongoose;

const userSchema = new Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true,
      immutable: true },
    password: { type: String, required: true },
    role: { 
      type: String, 
      enum: ['admin', 'futsal_owner', 'player'], 
      required: true 
    },
    phone: { 
      type: String, 
      default: '',
      validate: {
        validator: function (v) {
          return /^[0-9]{10}$/.test(v);
        },
        message: props => `${props.value} is not a valid phone number!`
      },
      required: false 
    },
    profilePicture: { 
      type: String, 
      default: 'https://example.com/default-profile.png'
    },
    tokens: [{ type: String }],
    //isActive: { type: Boolean, default: true },
    //locked: { type: Boolean, default: false },  // For lock/unlock
    //banned: { type: Boolean, default: false },  // For banning
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);
export default User;
