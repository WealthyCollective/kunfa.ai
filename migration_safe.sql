-- Safe migration that skips existing objects

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum (with IF NOT EXISTS via DO blocks)
DO $$ BEGIN
    CREATE TYPE "Plan" AS ENUM ('STARTER', 'PROFESSIONAL', 'ENTERPRISE');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "Role" AS ENUM ('OWNER', 'ADMIN', 'DEAL_LEAD', 'IC_MEMBER', 'REVIEWER', 'VIEWER');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "DealType" AS ENUM ('VC', 'PE', 'DEBT', 'SECONDARY', 'SPV');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "DealStatus" AS ENUM ('ACTIVE', 'ON_HOLD', 'CLOSED_WON', 'CLOSED_LOST', 'ARCHIVED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "Priority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "DocumentType" AS ENUM ('PITCH_DECK', 'FINANCIAL_MODEL', 'CAP_TABLE', 'LEGAL', 'DATA_ROOM', 'OTHER');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "VoteDecision" AS ENUM ('STRONG_YES', 'YES', 'YES_WITH_CONDITIONS', 'ABSTAIN', 'NO', 'STRONG_NO', 'PENDING');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "ActivityType" AS ENUM ('CALL', 'EMAIL', 'MEETING', 'NOTE', 'STAGE_CHANGE', 'DOCUMENT_UPLOAD', 'VOTE', 'COMMENT');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "InviteStatus" AS ENUM ('PENDING', 'OPENED', 'SUBMITTED', 'EXPIRED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "IntegrationProvider" AS ENUM ('GMAIL', 'GOOGLE_CALENDAR', 'OUTLOOK', 'READ_AI', 'SLACK', 'CRUNCHBASE', 'PITCHBOOK', 'LINKEDIN', 'AFFINITY');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "InterestLevel" AS ENUM ('HIGH', 'MEDIUM', 'LOW');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "ExitType" AS ENUM ('IPO', 'ACQUISITION', 'SECONDARY', 'BUYBACK', 'WRITE_OFF');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- CreateTable (IF NOT EXISTS)
CREATE TABLE IF NOT EXISTS "Organization" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "logo" TEXT,
    "plan" "Plan" NOT NULL DEFAULT 'STARTER',
    "settings" JSONB NOT NULL DEFAULT '{}',
    "stripeCustomerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "User" (
    "id" TEXT NOT NULL,
    "clerkId" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "avatar" TEXT,
    "role" "Role" NOT NULL DEFAULT 'VIEWER',
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "lastLoginAt" TIMESTAMP(3),
    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Stage" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "color" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "automations" JSONB NOT NULL DEFAULT '[]',
    "organizationId" TEXT NOT NULL,
    CONSTRAINT "Stage_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Deal" (
    "id" TEXT NOT NULL,
    "dealType" "DealType" NOT NULL DEFAULT 'VC',
    "amount" DECIMAL(15,2),
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "valuation" DECIMAL(15,2),
    "teamScore" INTEGER,
    "marketScore" INTEGER,
    "tractionScore" INTEGER,
    "productScore" INTEGER,
    "competitiveScore" INTEGER,
    "efficiencyScore" INTEGER,
    "kunfaScore" INTEGER,
    "stageId" TEXT NOT NULL,
    "status" "DealStatus" NOT NULL DEFAULT 'ACTIVE',
    "priority" "Priority" NOT NULL DEFAULT 'MEDIUM',
    "companyId" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "source" TEXT,
    "tags" TEXT[],
    "customFields" JSONB NOT NULL DEFAULT '{}',
    "redFlags" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "closedAt" TIMESTAMP(3),
    CONSTRAINT "Deal_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Company" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "website" TEXT,
    "domain" TEXT,
    "description" TEXT,
    "logo" TEXT,
    "country" TEXT,
    "city" TEXT,
    "sector" TEXT[],
    "stage" TEXT,
    "linkedinUrl" TEXT,
    "crunchbaseUrl" TEXT,
    "pitchbookId" TEXT,
    "employeeCount" INTEGER,
    "fundingTotal" DECIMAL(15,2),
    "lastFundingDate" TIMESTAMP(3),
    "foundedYear" INTEGER,
    "businessModel" TEXT,
    "revenue" DECIMAL(15,2),
    "mrr" DECIMAL(15,2),
    "growthRate" INTEGER,
    "burnRate" DECIMAL(15,2),
    "runway" INTEGER,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "enrichedAt" TIMESTAMP(3),
    CONSTRAINT "Company_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Founder" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "title" TEXT,
    "linkedinUrl" TEXT,
    "twitterUrl" TEXT,
    "birthDate" TIMESTAMP(3),
    "bio" TEXT,
    "previousCompanies" JSONB NOT NULL DEFAULT '[]',
    "education" JSONB NOT NULL DEFAULT '[]',
    "companyId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Founder_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Document" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "DocumentType" NOT NULL,
    "category" TEXT,
    "url" TEXT NOT NULL,
    "s3Key" TEXT,
    "mimeType" TEXT,
    "size" INTEGER,
    "extractedText" TEXT,
    "embedding" DOUBLE PRECISION[] DEFAULT ARRAY[]::DOUBLE PRECISION[],
    "aiSummary" TEXT,
    "dealId" TEXT NOT NULL,
    "uploadedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processedAt" TIMESTAMP(3),
    CONSTRAINT "Document_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Vote" (
    "id" TEXT NOT NULL,
    "decision" "VoteDecision" NOT NULL,
    "weight" DOUBLE PRECISION,
    "conditions" TEXT,
    "notes" TEXT,
    "dealId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Vote_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Activity" (
    "id" TEXT NOT NULL,
    "type" "ActivityType" NOT NULL,
    "title" TEXT NOT NULL,
    "notes" TEXT,
    "duration" INTEGER,
    "scheduledAt" TIMESTAMP(3),
    "source" TEXT,
    "externalId" TEXT,
    "externalData" JSONB NOT NULL DEFAULT '{}',
    "attachments" JSONB NOT NULL DEFAULT '[]',
    "transcript" TEXT,
    "dealId" TEXT,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Activity_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Memo" (
    "id" TEXT NOT NULL,
    "recommendation" TEXT,
    "overallScore" INTEGER,
    "summary" TEXT,
    "sections" JSONB NOT NULL DEFAULT '{}',
    "sourcesUsed" JSONB NOT NULL DEFAULT '[]',
    "voiceNotes" JSONB NOT NULL DEFAULT '[]',
    "modelVersion" TEXT,
    "promptTokens" INTEGER,
    "completionTokens" INTEGER,
    "dealId" TEXT NOT NULL,
    "generatedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Memo_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Comment" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "dealId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "parentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Comment_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Contact" (
    "id" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "title" TEXT,
    "company" TEXT,
    "companyWebsite" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "linkedinUrl" TEXT,
    "twitterUrl" TEXT,
    "tags" TEXT[],
    "notes" TEXT,
    "source" TEXT,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Contact_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Invite" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "companyName" TEXT,
    "sector" TEXT,
    "token" TEXT NOT NULL,
    "status" "InviteStatus" NOT NULL DEFAULT 'PENDING',
    "organizationId" TEXT NOT NULL,
    "invitedById" TEXT,
    "sentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "openedAt" TIMESTAMP(3),
    "submittedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Invite_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Integration" (
    "id" TEXT NOT NULL,
    "provider" "IntegrationProvider" NOT NULL,
    "accessToken" TEXT NOT NULL,
    "refreshToken" TEXT,
    "expiresAt" TIMESTAMP(3),
    "settings" JSONB NOT NULL DEFAULT '{}',
    "lastSyncAt" TIMESTAMP(3),
    "syncStatus" TEXT,
    "organizationId" TEXT NOT NULL,
    "connectedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Integration_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "AuditLog" (
    "id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entityType" TEXT NOT NULL,
    "entityId" TEXT,
    "changes" JSONB NOT NULL DEFAULT '{}',
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "userId" TEXT,
    "userEmail" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "Notification" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "data" JSONB NOT NULL DEFAULT '{}',
    "read" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP(3),
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "WatchlistEntry" (
    "id" TEXT NOT NULL,
    "interestLevel" "InterestLevel" NOT NULL DEFAULT 'MEDIUM',
    "notes" TEXT,
    "lastCheckedAt" TIMESTAMP(3),
    "companyId" TEXT NOT NULL,
    "addedById" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "WatchlistEntry_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "PortfolioEntry" (
    "id" TEXT NOT NULL,
    "investedAmount" DECIMAL(15,2) NOT NULL,
    "investedDate" TIMESTAMP(3) NOT NULL,
    "ownershipPct" DECIMAL(5,2),
    "currentValue" DECIMAL(15,2),
    "lastValuationDate" TIMESTAMP(3),
    "exitDate" TIMESTAMP(3),
    "exitValue" DECIMAL(15,2),
    "exitType" "ExitType",
    "moic" DOUBLE PRECISION,
    "irr" DOUBLE PRECISION,
    "milestones" JSONB NOT NULL DEFAULT '[]',
    "notes" TEXT,
    "dealId" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "PortfolioEntry_pkey" PRIMARY KEY ("id")
);

-- Add missing columns to existing tables (safe - will fail silently if exists)
DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "teamScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "marketScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "tractionScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "productScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "competitiveScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "efficiencyScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD COLUMN "kunfaScore" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Vote" ADD COLUMN "weight" DOUBLE PRECISION;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Vote" ADD COLUMN "conditions" TEXT;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "foundedYear" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "businessModel" TEXT;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "revenue" DECIMAL(15,2);
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "mrr" DECIMAL(15,2);
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "growthRate" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "burnRate" DECIMAL(15,2);
EXCEPTION WHEN duplicate_column THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD COLUMN "runway" INTEGER;
EXCEPTION WHEN duplicate_column THEN null;
END $$;

-- CreateIndex (IF NOT EXISTS)
CREATE UNIQUE INDEX IF NOT EXISTS "Organization_slug_key" ON "Organization"("slug");
CREATE UNIQUE INDEX IF NOT EXISTS "Organization_stripeCustomerId_key" ON "Organization"("stripeCustomerId");
CREATE INDEX IF NOT EXISTS "Organization_slug_idx" ON "Organization"("slug");
CREATE UNIQUE INDEX IF NOT EXISTS "User_clerkId_key" ON "User"("clerkId");
CREATE UNIQUE INDEX IF NOT EXISTS "User_email_key" ON "User"("email");
CREATE INDEX IF NOT EXISTS "User_organizationId_idx" ON "User"("organizationId");
CREATE INDEX IF NOT EXISTS "User_clerkId_idx" ON "User"("clerkId");
CREATE UNIQUE INDEX IF NOT EXISTS "User_email_organizationId_key" ON "User"("email", "organizationId");
CREATE INDEX IF NOT EXISTS "Stage_organizationId_order_idx" ON "Stage"("organizationId", "order");
CREATE UNIQUE INDEX IF NOT EXISTS "Stage_organizationId_slug_key" ON "Stage"("organizationId", "slug");
CREATE INDEX IF NOT EXISTS "Deal_organizationId_stageId_idx" ON "Deal"("organizationId", "stageId");
CREATE INDEX IF NOT EXISTS "Deal_organizationId_status_idx" ON "Deal"("organizationId", "status");
CREATE INDEX IF NOT EXISTS "Deal_companyId_idx" ON "Deal"("companyId");
CREATE INDEX IF NOT EXISTS "Deal_ownerId_idx" ON "Deal"("ownerId");
CREATE INDEX IF NOT EXISTS "Company_organizationId_idx" ON "Company"("organizationId");
CREATE INDEX IF NOT EXISTS "Company_name_idx" ON "Company"("name");
CREATE UNIQUE INDEX IF NOT EXISTS "Company_domain_organizationId_key" ON "Company"("domain", "organizationId");
CREATE INDEX IF NOT EXISTS "Founder_companyId_idx" ON "Founder"("companyId");
CREATE INDEX IF NOT EXISTS "Document_dealId_idx" ON "Document"("dealId");
CREATE INDEX IF NOT EXISTS "Document_type_idx" ON "Document"("type");
CREATE INDEX IF NOT EXISTS "Vote_dealId_idx" ON "Vote"("dealId");
CREATE UNIQUE INDEX IF NOT EXISTS "Vote_dealId_userId_key" ON "Vote"("dealId", "userId");
CREATE INDEX IF NOT EXISTS "Activity_dealId_idx" ON "Activity"("dealId");
CREATE INDEX IF NOT EXISTS "Activity_userId_idx" ON "Activity"("userId");
CREATE INDEX IF NOT EXISTS "Activity_type_idx" ON "Activity"("type");
CREATE INDEX IF NOT EXISTS "Activity_source_idx" ON "Activity"("source");
CREATE INDEX IF NOT EXISTS "Memo_dealId_idx" ON "Memo"("dealId");
CREATE INDEX IF NOT EXISTS "Comment_dealId_idx" ON "Comment"("dealId");
CREATE INDEX IF NOT EXISTS "Contact_organizationId_idx" ON "Contact"("organizationId");
CREATE INDEX IF NOT EXISTS "Contact_email_idx" ON "Contact"("email");
CREATE INDEX IF NOT EXISTS "Contact_company_idx" ON "Contact"("company");
CREATE UNIQUE INDEX IF NOT EXISTS "Invite_token_key" ON "Invite"("token");
CREATE INDEX IF NOT EXISTS "Invite_organizationId_idx" ON "Invite"("organizationId");
CREATE INDEX IF NOT EXISTS "Invite_token_idx" ON "Invite"("token");
CREATE INDEX IF NOT EXISTS "Invite_status_idx" ON "Invite"("status");
CREATE UNIQUE INDEX IF NOT EXISTS "Integration_organizationId_provider_key" ON "Integration"("organizationId", "provider");
CREATE INDEX IF NOT EXISTS "AuditLog_organizationId_createdAt_idx" ON "AuditLog"("organizationId", "createdAt");
CREATE INDEX IF NOT EXISTS "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");
CREATE INDEX IF NOT EXISTS "AuditLog_userId_idx" ON "AuditLog"("userId");
CREATE INDEX IF NOT EXISTS "Notification_userId_read_idx" ON "Notification"("userId", "read");
CREATE INDEX IF NOT EXISTS "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");
CREATE INDEX IF NOT EXISTS "WatchlistEntry_organizationId_idx" ON "WatchlistEntry"("organizationId");
CREATE INDEX IF NOT EXISTS "WatchlistEntry_interestLevel_idx" ON "WatchlistEntry"("interestLevel");
CREATE UNIQUE INDEX IF NOT EXISTS "WatchlistEntry_companyId_organizationId_key" ON "WatchlistEntry"("companyId", "organizationId");
CREATE UNIQUE INDEX IF NOT EXISTS "PortfolioEntry_dealId_key" ON "PortfolioEntry"("dealId");
CREATE INDEX IF NOT EXISTS "PortfolioEntry_organizationId_idx" ON "PortfolioEntry"("organizationId");
CREATE INDEX IF NOT EXISTS "PortfolioEntry_exitType_idx" ON "PortfolioEntry"("exitType");

-- AddForeignKey (with IF NOT EXISTS check)
DO $$ BEGIN
    ALTER TABLE "User" ADD CONSTRAINT "User_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Stage" ADD CONSTRAINT "Stage_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD CONSTRAINT "Deal_stageId_fkey" FOREIGN KEY ("stageId") REFERENCES "Stage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD CONSTRAINT "Deal_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD CONSTRAINT "Deal_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Deal" ADD CONSTRAINT "Deal_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Company" ADD CONSTRAINT "Company_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Founder" ADD CONSTRAINT "Founder_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Document" ADD CONSTRAINT "Document_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Vote" ADD CONSTRAINT "Vote_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Vote" ADD CONSTRAINT "Vote_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Activity" ADD CONSTRAINT "Activity_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Activity" ADD CONSTRAINT "Activity_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Memo" ADD CONSTRAINT "Memo_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Comment" ADD CONSTRAINT "Comment_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Comment" ADD CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Comment" ADD CONSTRAINT "Comment_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Comment"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Contact" ADD CONSTRAINT "Contact_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Invite" ADD CONSTRAINT "Invite_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Integration" ADD CONSTRAINT "Integration_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_addedById_fkey" FOREIGN KEY ("addedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "PortfolioEntry" ADD CONSTRAINT "PortfolioEntry_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "PortfolioEntry" ADD CONSTRAINT "PortfolioEntry_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;
