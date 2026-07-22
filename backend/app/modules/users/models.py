from datetime import datetime
from sqlalchemy import BigInteger, String, Boolean, DateTime, CheckConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)

    username: Mapped[str] = mapped_column(String(32), unique=True, nullable=False, index=True)
    display_name: Mapped[str] = mapped_column(String(100), nullable=False)

    avatar_url: Mapped[str | None] = mapped_column(String, nullable=True)
    profile_banner_url: Mapped[str | None] = mapped_column(String, nullable=True)

    privacy_default: Mapped[str] = mapped_column(String(20), server_default="friends", nullable=False)
    notify_meeting_rsvp_changes: Mapped[bool] = mapped_column(Boolean, server_default="true", nullable=False)
    theme: Mapped[str] = mapped_column(String(10), server_default="system", nullable=False)
    language: Mapped[str] = mapped_column(String(10), server_default="ru", nullable=False)
    timezone: Mapped[str] = mapped_column(String(50), server_default="UTC", nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    __table_args__ = (
        CheckConstraint("privacy_default IN ('everyone', 'friends', 'only_me')", name="chk_privacy_default"),
        CheckConstraint("theme IN ('light', 'dark', 'system')", name="chk_theme"),
        CheckConstraint("username ~* '^[a-zA-Z0-9_]{3,32}$'", name="chk_username_format"),
    )