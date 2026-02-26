-- =============================================
-- 준비 일정 테이블 생성
-- =============================================

CREATE TABLE preparation_schedule (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    
    -- 고객 정보 (빠른 조회용)
    user_id BIGINT,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    
    -- 준비 날짜 및 시간
    prep_date DATE NOT NULL,
    prep_time TEXT NOT NULL,
    
    -- 주문 정보
    plan TEXT NOT NULL,
    plan_count INTEGER NOT NULL,
    pickup_type TEXT NOT NULL,
    days TEXT NOT NULL,
    
    -- 식단 정보
    topping TEXT,
    exclude_items TEXT,
    special_request TEXT,
    
    -- 상태 관리
    is_prepared BOOLEAN DEFAULT false,
    is_picked_up BOOLEAN DEFAULT false,
    is_cancelled BOOLEAN DEFAULT false,
    
    -- 메타데이터
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 인덱스를 위한 제약조건
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- 인덱스 생성 (빠른 조회)
CREATE INDEX idx_prep_date ON preparation_schedule(prep_date);
CREATE INDEX idx_prep_date_time ON preparation_schedule(prep_date, prep_time);
CREATE INDEX idx_order_id ON preparation_schedule(order_id);
CREATE INDEX idx_is_cancelled ON preparation_schedule(is_cancelled);

-- 업데이트 시간 자동 갱신
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_preparation_schedule_updated_at
    BEFORE UPDATE ON preparation_schedule
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) 설정
ALTER TABLE preparation_schedule ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽을 수 있음
CREATE POLICY "Enable read access for all users" ON preparation_schedule
    FOR SELECT USING (true);

-- 인증된 사용자만 삽입/수정/삭제
CREATE POLICY "Enable insert for authenticated users only" ON preparation_schedule
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users only" ON preparation_schedule
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for authenticated users only" ON preparation_schedule
    FOR DELETE USING (true);

-- 완료!
COMMENT ON TABLE preparation_schedule IS '주문별 준비 일정 테이블 - 각 주문의 모든 픽업 날짜를 미리 계산하여 저장';
