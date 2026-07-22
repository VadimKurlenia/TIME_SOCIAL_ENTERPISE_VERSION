from datetime import datetime
from pydantic import BaseModel, ConfigDict, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    username: str = Field(min_length=3, max_length=32, pattern=r"^[a-zA-Z0-9_]+$")
    display_name: str = Field(min_length=1, max_length=100)

class UserLogin(BaseModel):
    login: str 
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    username: str
    display_name: str
    avatar_url: str | None = None
    profile_banner_url: str | None = None
    privacy_default: str
    theme: str
    language: str
    timezone: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"