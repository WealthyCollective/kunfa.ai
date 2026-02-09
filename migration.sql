
-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Plan" AS ENUM ('STARTER', 'PROFESSIONAL', 'ENTERPRISE');

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('OWNER', 'ADMIN', 'DEAL_LEAD', 'IC_MEMBER', 'REVIEWER', 'VIEWER');

-- CreateEnum
CREATE TYPE "DealType" AS ENUM ('VC', 'PE', 'DEBT', 'SECONDARY', 'SPV');

-- CreateEnum
CREATE TYPE "DealStatus" AS ENUM ('ACTIVE', 'ON_HOLD', 'CLOSED_WON', 'CLOSED_LOST', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "Priority" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "DocumentType" AS ENUM ('PITCH_DECK', 'FINANCIAL_MODEL', 'CAP_TABLE', 'LEGAL', 'DATA_ROOM', 'OTHER');

-- CreateEnum
CREATE TYPE "VoteDecision" AS ENUM ('STRONG_YES', 'YES', 'YES_WITH_CONDITIONS', 'ABSTAIN', 'NO', 'STRONG_NO', 'PENDING');

-- CreateEnum
CREATE TYPE "ActivityType" AS ENUM ('CALL', 'EMAIL', 'MEETING', 'NOTE', 'STAGE_CHANGE', 'DOCUMENT_UPLOAD', 'VOTE', 'COMMENT');

-- CreateEnum
CREATE TYPE "InviteStatus" AS ENUM ('PENDING', 'OPENED', 'SUBMITTED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "IntegrationProvider" AS ENUM ('GMAIL', 'GOOGLE_CALENDAR', 'OUTLOOK', 'READ_AI', 'SLACK', 'CRUNCHBASE', 'PITCHBOOK', 'LINKEDIN', 'AFFINITY');

-- CreateEnum
CREATE TYPE "InterestLevel" AS ENUM ('HIGH', 'MEDIUM', 'LOW');

-- CreateEnum
CREATE TYPE "ExitType" AS ENUM ('IPO', 'ACQUISITION', 'SECONDARY', 'BUYBACK', 'WRITE_OFF');

-- CreateTable
CREATE TABLE "Organization" (
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

-- CreateTable
CREATE TABLE "User" (
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

-- CreateTable
CREATE TABLE "Stage" (
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

-- CreateTable
CREATE TABLE "Deal" (
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

-- CreateTable
CREATE TABLE "Company" (
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

-- CreateTable
CREATE TABLE "Founder" (
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

-- CreateTable
CREATE TABLE "Document" (
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

-- CreateTable
CREATE TABLE "Vote" (
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

-- CreateTable
CREATE TABLE "Activity" (
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

-- CreateTable
CREATE TABLE "Memo" (
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

-- CreateTable
CREATE TABLE "Comment" (
    "id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "dealId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "parentId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Comment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Contact" (
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

-- CreateTable
CREATE TABLE "Invite" (
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

-- CreateTable
CREATE TABLE "Integration" (
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

-- CreateTable
CREATE TABLE "AuditLog" (
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

-- CreateTable
CREATE TABLE "Notification" (
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

-- CreateTable
CREATE TABLE "WatchlistEntry" (
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

-- CreateTable
CREATE TABLE "PortfolioEntry" (
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

-- CreateIndex
CREATE UNIQUE INDEX "Organization_slug_key" ON "Organization"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Organization_stripeCustomerId_key" ON "Organization"("stripeCustomerId");

-- CreateIndex
CREATE INDEX "Organization_slug_idx" ON "Organization"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "User_clerkId_key" ON "User"("clerkId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_organizationId_idx" ON "User"("organizationId");

-- CreateIndex
CREATE INDEX "User_clerkId_idx" ON "User"("clerkId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_organizationId_key" ON "User"("email", "organizationId");

-- CreateIndex
CREATE INDEX "Stage_organizationId_order_idx" ON "Stage"("organizationId", "order");

-- CreateIndex
CREATE UNIQUE INDEX "Stage_organizationId_slug_key" ON "Stage"("organizationId", "slug");

-- CreateIndex
CREATE INDEX "Deal_organizationId_stageId_idx" ON "Deal"("organizationId", "stageId");

-- CreateIndex
CREATE INDEX "Deal_organizationId_status_idx" ON "Deal"("organizationId", "status");

-- CreateIndex
CREATE INDEX "Deal_companyId_idx" ON "Deal"("companyId");

-- CreateIndex
CREATE INDEX "Deal_ownerId_idx" ON "Deal"("ownerId");

-- CreateIndex
CREATE INDEX "Company_organizationId_idx" ON "Company"("organizationId");

-- CreateIndex
CREATE INDEX "Company_name_idx" ON "Company"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Company_domain_organizationId_key" ON "Company"("domain", "organizationId");

-- CreateIndex
CREATE INDEX "Founder_companyId_idx" ON "Founder"("companyId");

-- CreateIndex
CREATE INDEX "Document_dealId_idx" ON "Document"("dealId");

-- CreateIndex
CREATE INDEX "Document_type_idx" ON "Document"("type");

-- CreateIndex
CREATE INDEX "Vote_dealId_idx" ON "Vote"("dealId");

-- CreateIndex
CREATE UNIQUE INDEX "Vote_dealId_userId_key" ON "Vote"("dealId", "userId");

-- CreateIndex
CREATE INDEX "Activity_dealId_idx" ON "Activity"("dealId");

-- CreateIndex
CREATE INDEX "Activity_userId_idx" ON "Activity"("userId");

-- CreateIndex
CREATE INDEX "Activity_type_idx" ON "Activity"("type");

-- CreateIndex
CREATE INDEX "Activity_source_idx" ON "Activity"("source");

-- CreateIndex
CREATE INDEX "Memo_dealId_idx" ON "Memo"("dealId");

-- CreateIndex
CREATE INDEX "Comment_dealId_idx" ON "Comment"("dealId");

-- CreateIndex
CREATE INDEX "Contact_organizationId_idx" ON "Contact"("organizationId");

-- CreateIndex
CREATE INDEX "Contact_email_idx" ON "Contact"("email");

-- CreateIndex
CREATE INDEX "Contact_company_idx" ON "Contact"("company");

-- CreateIndex
CREATE UNIQUE INDEX "Invite_token_key" ON "Invite"("token");

-- CreateIndex
CREATE INDEX "Invite_organizationId_idx" ON "Invite"("organizationId");

-- CreateIndex
CREATE INDEX "Invite_token_idx" ON "Invite"("token");

-- CreateIndex
CREATE INDEX "Invite_status_idx" ON "Invite"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Integration_organizationId_provider_key" ON "Integration"("organizationId", "provider");

-- CreateIndex
CREATE INDEX "AuditLog_organizationId_createdAt_idx" ON "AuditLog"("organizationId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_idx" ON "AuditLog"("entityType", "entityId");

-- CreateIndex
CREATE INDEX "AuditLog_userId_idx" ON "AuditLog"("userId");

-- CreateIndex
CREATE INDEX "Notification_userId_read_idx" ON "Notification"("userId", "read");

-- CreateIndex
CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "WatchlistEntry_organizationId_idx" ON "WatchlistEntry"("organizationId");

-- CreateIndex
CREATE INDEX "WatchlistEntry_interestLevel_idx" ON "WatchlistEntry"("interestLevel");

-- CreateIndex
CREATE UNIQUE INDEX "WatchlistEntry_companyId_organizationId_key" ON "WatchlistEntry"("companyId", "organizationId");

-- CreateIndex
CREATE UNIQUE INDEX "PortfolioEntry_dealId_key" ON "PortfolioEntry"("dealId");

-- CreateIndex
CREATE INDEX "PortfolioEntry_organizationId_idx" ON "PortfolioEntry"("organizationId");

-- CreateIndex
CREATE INDEX "PortfolioEntry_exitType_idx" ON "PortfolioEntry"("exitType");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Stage" ADD CONSTRAINT "Stage_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_stageId_fkey" FOREIGN KEY ("stageId") REFERENCES "Stage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Deal" ADD CONSTRAINT "Deal_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Company" ADD CONSTRAINT "Company_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Founder" ADD CONSTRAINT "Founder_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Vote" ADD CONSTRAINT "Vote_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Vote" ADD CONSTRAINT "Vote_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Memo" ADD CONSTRAINT "Memo_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Comment"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Contact" ADD CONSTRAINT "Contact_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invite" ADD CONSTRAINT "Invite_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Integration" ADD CONSTRAINT "Integration_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_companyId_fkey" FOREIGN KEY ("companyId") REFERENCES "Company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_addedById_fkey" FOREIGN KEY ("addedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WatchlistEntry" ADD CONSTRAINT "WatchlistEntry_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PortfolioEntry" ADD CONSTRAINT "PortfolioEntry_dealId_fkey" FOREIGN KEY ("dealId") REFERENCES "Deal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PortfolioEntry" ADD CONSTRAINT "PortfolioEntry_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

