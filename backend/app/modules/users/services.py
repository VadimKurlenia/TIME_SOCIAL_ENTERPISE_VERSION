from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, verify_password, create_access_token
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import UserCreate, UserLogin, Token, UserOut


class AuthService:
    def __init__(self, db: AsyncSession):
        self.repo = UserRepository(db)

    async def register_user(self, user_data: UserCreate) -> UserOut:
        if await self.repo.get_by_email(user_data.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Пользователь с таким email уже существует",
            )

        if await self.repo.get_by_username(user_data.username):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username уже занят",
            )

        hashed_pwd = hash_password(user_data.password)
        user = await self.repo.create(user_data, password_hash=hashed_pwd)
        return UserOut.model_validate(user)

    async def authenticate_user(self, login_data: UserLogin) -> Token:
        user = await self.repo.get_by_email_or_username(login_data.login)
        if not user or not verify_password(login_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Неверный логин или пароль",
                headers={"WWW-Authenticate": "Bearer"},
            )

        access_token = create_access_token(data={"sub": str(user.id)})
        return Token(access_token=access_token)